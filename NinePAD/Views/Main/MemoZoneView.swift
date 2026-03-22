import SwiftUI

struct MemoZoneView: View {
    @EnvironmentObject var authService: AuthService
    @ObservedObject var snippetViewModel: SnippetViewModel
    @StateObject private var viewModel = MemoViewModel()
    // 새 노트는 독립 Window로 열림
    @Environment(\.openWindow) var openWindow
    @State private var pushingMemoId: UUID?
    @State private var isPushingAll = false
    @State private var pushAllDone = false

    var body: some View {
        VStack(spacing: 0) {
            // 검색바
            searchBar

            // Zone Label
            HStack {
                Text("NOTES")
                    .font(.system(size: AppTheme.zoneLabelSize, weight: AppTheme.zoneLabelWeight))
                    .foregroundColor(AppTheme.zoneLabel)

                Spacer()

                if viewModel.isLoading {
                    ProgressView()
                        .controlSize(.mini)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)

            // 에러
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption2)
                    .foregroundColor(AppTheme.danger)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
            }

            // 노트 리스트
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(viewModel.filteredMemos) { memo in
                        MemoRowView(
                            memo: memo,
                            onTap: {
                                openWindow(value: memo.id)
                            },
                            onDelete: { Task { await viewModel.deleteMemo(id: memo.id) } }
                        )
                    }
                }
                .padding(.horizontal, 8)
            }

            // 하단바
            bottomBar
        }
        .background(AppTheme.memoZoneBg)
        .onAppear {
            if let user = authService.currentUser, let orgId = user.orgId {
                viewModel.setup(userId: user.id, orgId: orgId)
            }
        }
        .onDisappear {
            Task { await viewModel.stopRealtime() }
        }
        // 메모 상세는 독립 Window로 열림 (openWindow(value: memo.id))
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textTertiary)

            TextField("노트 검색...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textPrimary)

            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppTheme.inputBg)
        .cornerRadius(AppTheme.cornerRadius)
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            Button(action: {
                openWindow(value: MemoWindowHelper.newNoteId)
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 11))
                    Text("새 노트")
                        .font(.system(size: 12))
                }
                .foregroundColor(AppTheme.accent)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("\(viewModel.filteredMemos.count)개 노트")
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textTertiary)

            Spacer()

            // 전체 푸시 (admin만)
            if authService.currentUser?.isAdmin == true {
                Button(action: pushAllMemos) {
                    if isPushingAll {
                        ProgressView().controlSize(.mini)
                    } else {
                        Image(systemName: pushAllDone ? "checkmark" : "arrow.up.to.line")
                            .font(.system(size: 11))
                            .foregroundColor(pushAllDone ? AppTheme.success : AppTheme.accent)
                    }
                }
                .buttonStyle(.plain)
                .disabled(isPushingAll)
                .help("전체 메모 Git 푸시")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppTheme.border.opacity(0.5))
    }

    private func pushMemo(_ memo: Memo) {
        pushingMemoId = memo.id
        Task {
            do {
                try await GitService.pushMemo(memo)
            } catch {
                viewModel.errorMessage = error.localizedDescription
            }
            pushingMemoId = nil
        }
    }

    private func pushAllMemos() {
        isPushingAll = true
        Task {
            do {
                try await GitService.pushAllMemos(viewModel.memos)
                pushAllDone = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    pushAllDone = false
                }
            } catch {
                viewModel.errorMessage = error.localizedDescription
            }
            isPushingAll = false
        }
    }
}
