import SwiftUI

struct TrashView: View {
    @EnvironmentObject var authService: AuthService
    @State private var trashedMemos: [Memo] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let memoService = MemoService()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M/d HH:mm"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TRASH")
                    .font(.system(size: AppTheme.zoneLabelSize, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)

                Spacer()

                if isLoading {
                    ProgressView().controlSize(.mini)
                }

                Button(action: { Task { await loadTrash() } }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }

            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.danger)
            }

            if trashedMemos.isEmpty {
                Text("휴지통이 비어있습니다.")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textTertiary)
                    .padding(.vertical, 8)
            } else {
                ForEach(trashedMemos) { memo in
                    trashRow(memo)
                }
            }
        }
        .padding(16)
        .task { await loadTrash() }
    }

    @ViewBuilder
    private func trashRow(_ memo: Memo) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(memo.title.isEmpty ? "제목 없음" : memo.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppTheme.textPrimary)

                if let deletedAt = memo.deletedAt {
                    Text("삭제: \(Self.dateFormatter.string(from: deletedAt))")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.textTertiary)
                }
            }

            Spacer()

            // 복원
            Button(action: {
                Task { await restore(memo) }
            }) {
                Text("복원")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.accent)
            }
            .buttonStyle(.plain)

            // 영구 삭제
            Button(action: {
                Task { await permanentDelete(memo) }
            }) {
                Text("영구삭제")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.danger)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
    }

    private func loadTrash() async {
        guard let user = authService.currentUser, let orgId = user.orgId else { return }
        isLoading = true
        do {
            trashedMemos = try await memoService.fetchDeletedMemos(orgId: orgId)
        } catch {
            errorMessage = "휴지통 로드 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }

    private func restore(_ memo: Memo) async {
        do {
            try await memoService.restoreMemo(id: memo.id)
            trashedMemos.removeAll { $0.id == memo.id }
        } catch {
            errorMessage = "복원 실패: \(error.localizedDescription)"
        }
    }

    private func permanentDelete(_ memo: Memo) async {
        do {
            try await memoService.permanentlyDeleteMemo(id: memo.id)
            trashedMemos.removeAll { $0.id == memo.id }
        } catch {
            errorMessage = "영구 삭제 실패: \(error.localizedDescription)"
        }
    }
}
