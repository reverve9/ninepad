import Foundation
import Supabase
import Realtime

final class SnippetService {
    private let client = SupabaseManager.shared.client
    private var channel: RealtimeChannelV2?

    // MARK: - Fetch

    func fetchSnippets(orgId: UUID) async throws -> [Snippet] {
        let snippets: [Snippet] = try await client.from("snippets")
            .select()
            .eq("org_id", value: orgId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
        return snippets
    }

    // MARK: - Create

    func createSnippet(userId: UUID, orgId: UUID, title: String, content: String) async throws -> Snippet {
        let snippet: Snippet = try await client.from("snippets")
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
        return snippet
    }

    // MARK: - Update

    func updateSnippet(id: UUID, title: String, content: String) async throws -> Snippet {
        let snippet: Snippet = try await client.from("snippets")
            .update([
                "title": title,
                "content": content
            ])
            .eq("id", value: id.uuidString)
            .select()
            .single()
            .execute()
            .value
        return snippet
    }

    // MARK: - Delete

    func deleteSnippet(id: UUID) async throws {
        try await client.from("snippets")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Realtime

    func subscribe(
        orgId: UUID,
        onInsert: @escaping (Snippet) -> Void,
        onUpdate: @escaping (Snippet) -> Void,
        onDelete: @escaping (UUID) -> Void
    ) async {
        let channel = client.realtimeV2.channel("snippets-\(orgId.uuidString)")

        let insertions = channel.postgresChange(InsertAction.self, table: "snippets", filter: "org_id=eq.\(orgId.uuidString)")
        let updates = channel.postgresChange(UpdateAction.self, table: "snippets", filter: "org_id=eq.\(orgId.uuidString)")
        let deletions = channel.postgresChange(DeleteAction.self, table: "snippets", filter: "org_id=eq.\(orgId.uuidString)")

        await channel.subscribe()
        self.channel = channel

        Task {
            for await insertion in insertions {
                if let snippet = try? insertion.decodeRecord(as: Snippet.self, decoder: JSONDecoder.supabaseDecoder) {
                    onInsert(snippet)
                }
            }
        }

        Task {
            for await update in updates {
                if let snippet = try? update.decodeRecord(as: Snippet.self, decoder: JSONDecoder.supabaseDecoder) {
                    onUpdate(snippet)
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
