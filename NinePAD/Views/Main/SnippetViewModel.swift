import Foundation
import SwiftUI

@MainActor
final class SnippetViewModel: ObservableObject {
    @Published var snippets: [Snippet] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let snippetService = SnippetService()
    private var userId: UUID?
    private var orgId: UUID?

    // MARK: - Setup

    func setup(userId: UUID, orgId: UUID) {
        self.userId = userId
        self.orgId = orgId
        Task {
            await loadSnippets()
            await startRealtime()
        }
    }

    // MARK: - Load

    func loadSnippets() async {
        guard let orgId else { return }
        isLoading = true
        errorMessage = nil
        do {
            snippets = try await snippetService.fetchSnippets(orgId: orgId)
        } catch {
            errorMessage = "스니펫 로드 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - Create

    func createSnippet(title: String, content: String) async {
        guard let userId, let orgId else { return }
        do {
            let snippet = try await snippetService.createSnippet(
                userId: userId,
                orgId: orgId,
                title: title,
                content: content
            )
            if !snippets.contains(where: { $0.id == snippet.id }) {
                snippets.insert(snippet, at: 0)
            }
        } catch {
            errorMessage = "스니펫 생성 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Create from Memo

    func createFromMemo(title: String, content: String) async {
        await createSnippet(title: title, content: content)
    }

    // MARK: - Update

    func updateSnippet(id: UUID, title: String, content: String) async {
        do {
            let updated = try await snippetService.updateSnippet(id: id, title: title, content: content)
            if let index = snippets.firstIndex(where: { $0.id == id }) {
                snippets[index] = updated
            }
        } catch {
            errorMessage = "스니펫 수정 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Delete

    func deleteSnippet(id: UUID) async {
        do {
            try await snippetService.deleteSnippet(id: id)
            snippets.removeAll { $0.id == id }
        } catch {
            errorMessage = "스니펫 삭제 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Realtime

    private func startRealtime() async {
        guard let orgId else { return }
        await snippetService.subscribe(
            orgId: orgId,
            onInsert: { [weak self] snippet in
                Task { @MainActor in
                    guard let self else { return }
                    if !self.snippets.contains(where: { $0.id == snippet.id }) {
                        self.snippets.insert(snippet, at: 0)
                    }
                }
            },
            onUpdate: { [weak self] snippet in
                Task { @MainActor in
                    guard let self else { return }
                    if let index = self.snippets.firstIndex(where: { $0.id == snippet.id }) {
                        self.snippets[index] = snippet
                    }
                }
            },
            onDelete: { [weak self] id in
                Task { @MainActor in
                    self?.snippets.removeAll { $0.id == id }
                }
            }
        )
    }

    func stopRealtime() async {
        await snippetService.unsubscribe()
    }
}
