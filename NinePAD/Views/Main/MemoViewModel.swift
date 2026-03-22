import Foundation
import SwiftUI

@MainActor
final class MemoViewModel: ObservableObject {
    @Published var memos: [Memo] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let memoService = MemoService()
    private var userId: UUID?
    private var orgId: UUID?

    var filteredMemos: [Memo] {
        if searchText.isEmpty { return memos }
        return memos.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Setup

    func setup(userId: UUID, orgId: UUID) {
        self.userId = userId
        self.orgId = orgId
        Task {
            await loadMemos()
            await startRealtime()
        }
    }

    // MARK: - Load

    func loadMemos() async {
        guard let orgId else { return }
        isLoading = true
        errorMessage = nil
        do {
            memos = try await memoService.fetchMemos(orgId: orgId)
        } catch {
            errorMessage = "메모 로드 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - Create

    func createMemo(title: String, content: String) async {
        guard let userId, let orgId else { return }
        do {
            let memo = try await memoService.createMemo(
                userId: userId,
                orgId: orgId,
                title: title,
                content: content
            )
            // Realtime이 반영하지만, 즉각 UI 반영을 위해 로컬 삽입
            if !memos.contains(where: { $0.id == memo.id }) {
                memos.insert(memo, at: 0)
            }
        } catch {
            errorMessage = "메모 생성 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Update

    func updateMemo(id: UUID, title: String, content: String) async {
        do {
            let updated = try await memoService.updateMemo(id: id, title: title, content: content)
            if let index = memos.firstIndex(where: { $0.id == id }) {
                memos[index] = updated
            }
        } catch {
            errorMessage = "메모 수정 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Soft Delete

    func deleteMemo(id: UUID) async {
        do {
            try await memoService.deleteMemo(id: id)
            memos.removeAll { $0.id == id }
        } catch {
            errorMessage = "노트 삭제 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Trash (휴지통)

    @Published var trashedMemos: [Memo] = []

    func loadTrashedMemos() async {
        guard let orgId else { return }
        do {
            trashedMemos = try await memoService.fetchDeletedMemos(orgId: orgId)
        } catch {
            errorMessage = "휴지통 로드 실패: \(error.localizedDescription)"
        }
    }

    func restoreMemo(id: UUID) async {
        do {
            try await memoService.restoreMemo(id: id)
            trashedMemos.removeAll { $0.id == id }
            await loadMemos()
        } catch {
            errorMessage = "복원 실패: \(error.localizedDescription)"
        }
    }

    func permanentlyDeleteMemo(id: UUID) async {
        do {
            try await memoService.permanentlyDeleteMemo(id: id)
            trashedMemos.removeAll { $0.id == id }
        } catch {
            errorMessage = "영구 삭제 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Realtime

    private func startRealtime() async {
        guard let orgId else { return }
        try? await memoService.subscribe(
            orgId: orgId,
            onInsert: { [weak self] memo in
                Task { @MainActor in
                    guard let self else { return }
                    if !self.memos.contains(where: { $0.id == memo.id }) {
                        self.memos.insert(memo, at: 0)
                    }
                }
            },
            onUpdate: { [weak self] memo in
                Task { @MainActor in
                    guard let self else { return }
                    if let index = self.memos.firstIndex(where: { $0.id == memo.id }) {
                        self.memos[index] = memo
                    }
                }
            },
            onDelete: { [weak self] id in
                Task { @MainActor in
                    self?.memos.removeAll { $0.id == id }
                }
            }
        )
    }

    func stopRealtime() async {
        await memoService.unsubscribe()
    }
}
