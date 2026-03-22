import Foundation
import Supabase
import Realtime

final class MemoService {
    private let client = SupabaseManager.shared.client
    private var channel: RealtimeChannelV2?

    // MARK: - Fetch

    func fetchMemos(orgId: UUID) async throws -> [Memo] {
        let memos: [Memo] = try await client.from("memos")
            .select()
            .eq("org_id", value: orgId.uuidString)
            .is("deleted_at", value: nil)
            .order("updated_at", ascending: false)
            .execute()
            .value
        return memos
    }

    // MARK: - Fetch Deleted (휴지통)

    func fetchDeletedMemos(orgId: UUID) async throws -> [Memo] {
        let memos: [Memo] = try await client.from("memos")
            .select()
            .eq("org_id", value: orgId.uuidString)
            .not("deleted_at", operator: .is, value: "null")
            .order("deleted_at", ascending: false)
            .execute()
            .value
        return memos
    }

    // MARK: - Create

    func createMemo(userId: UUID, orgId: UUID, title: String, content: String) async throws -> Memo {
        let memo: Memo = try await client.from("memos")
            .insert([
                "user_id": userId.uuidString,
                "org_id": orgId.uuidString,
                "title": title,
                "content": content
            ])
            .select()
            .single()
            .execute()
            .value
        return memo
    }

    // MARK: - Update

    func updateMemo(id: UUID, title: String, content: String) async throws -> Memo {
        let memo: Memo = try await client.from("memos")
            .update([
                "title": title,
                "content": content
            ])
            .eq("id", value: id.uuidString)
            .select()
            .single()
            .execute()
            .value
        return memo
    }

    // MARK: - Pin Toggle

    func togglePin(id: UUID, isPinned: Bool) async throws -> Memo {
        struct PinUpdate: Encodable {
            let is_pinned: Bool
        }
        let memo: Memo = try await client.from("memos")
            .update(PinUpdate(is_pinned: isPinned))
            .eq("id", value: id.uuidString)
            .select()
            .single()
            .execute()
            .value
        return memo
    }

    // MARK: - Soft Delete

    func deleteMemo(id: UUID) async throws {
        _ = try await client.from("memos")
            .update(["deleted_at": ISO8601DateFormatter().string(from: Date())])
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Restore

    func restoreMemo(id: UUID) async throws {
        // deleted_at을 NULL로 설정하여 복원
        struct NullUpdate: Encodable {
            let deleted_at: String? = nil
        }
        _ = try await client.from("memos")
            .update(NullUpdate())
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Hard Delete (영구 삭제)

    func permanentlyDeleteMemo(id: UUID) async throws {
        _ = try await client.from("memos")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Realtime

    func subscribe(
        orgId: UUID,
        onInsert: @escaping (Memo) -> Void,
        onUpdate: @escaping (Memo) -> Void,
        onDelete: @escaping (UUID) -> Void
    ) async throws {
        let channel = client.realtimeV2.channel("memos-\(orgId.uuidString)")

        let insertions = channel.postgresChange(InsertAction.self, schema: "public", table: "memos", filter: .eq("org_id", value: orgId.uuidString))
        let updates = channel.postgresChange(UpdateAction.self, schema: "public", table: "memos", filter: .eq("org_id", value: orgId.uuidString))
        let deletions = channel.postgresChange(DeleteAction.self, schema: "public", table: "memos", filter: .eq("org_id", value: orgId.uuidString))

        try await channel.subscribeWithError()
        self.channel = channel

        Task {
            for await insertion in insertions {
                if let memo = try? insertion.decodeRecord(as: Memo.self, decoder: JSONDecoder.supabaseDecoder) {
                    onInsert(memo)
                }
            }
        }

        Task {
            for await update in updates {
                if let memo = try? update.decodeRecord(as: Memo.self, decoder: JSONDecoder.supabaseDecoder) {
                    onUpdate(memo)
                }
            }
        }

        Task {
            for await deletion in deletions {
                if let idString = deletion.oldRecord["id"]?.stringValue,
                   let id = UUID(uuidString: idString) {
                    onDelete(id)
                }
            }
        }
    }

    func unsubscribe() async {
        if let channel {
            await channel.unsubscribe()
            self.channel = nil
        }
    }
}

// MARK: - JSONDecoder Extension

extension JSONDecoder {
    static let supabaseDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = formatter.date(from: dateString) {
                return date
            }
            // Fallback without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(dateString)")
        }
        return decoder
    }()
}
