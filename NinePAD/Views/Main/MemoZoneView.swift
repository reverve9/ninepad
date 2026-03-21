import SwiftUI

struct MemoZoneView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = MemoViewModel()
    @State private var showNewMemo = false
    @State private var newTitle = ""
    @State private var newContent = ""

    var body: some View {
        VStack(spacing: 0) {
            // 검색바
            searchBar

            // Zone Label
            HStack {
                Text("MEMOS")
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

            // 에러 메시지
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption2)
                    .foregroundColor(AppTheme.danger)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
            }

            // 새 메모 인라인 입력
            if showNewMemo {
                newMemoForm
            }

            // 메모 리스트
            ScrollView {
                LazyVStack(spacing: 2) {
                    ForEach(viewModel.filteredMemos) { memo in
                        MemoRowView(
                            memo: memo,
                            onUpdate: { title, content in
                                Task { await viewModel.updateMemo(id: memo.id, title: title, content: content) }
                            },
                            onDelete: {
                                Task { await viewModel.deleteMemo(id: memo.id) }
                            }
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
            if let user = authService.currentUser {
                viewModel.setup(userId: user.id, orgId: user.orgId)
            }
        }
        .onDisappear {
            Task { await viewModel.stopRealtime() }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textTertiary)

            TextField("메모 검색...", text: $viewModel.searchText)
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

    // MARK: - New Memo Form

    private var newMemoForm: some View {
        VStack(spacing: 8) {
            TextField("제목", text: $newTitle)
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)

            TextEditor(text: $newContent)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 60, maxHeight: 100)

            HStack {
                Button("취소") {
                    resetNewMemo()
                }
                .buttonStyle(.plain)
                .foregroundColor(AppTheme.textTertiary)
                .font(.system(size: 12))

                Spacer()

                Button("저장") {
                    Task {
                        await viewModel.createMemo(title: newTitle, content: newContent)
                        resetNewMemo()
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(newTitle.isEmpty ? AppTheme.textTertiary : AppTheme.accent)
                .font(.system(size: 12, weight: .medium))
                .disabled(newTitle.isEmpty)
            }
        }
        .padding(12)
        .background(AppTheme.inputBg)
        .cornerRadius(AppTheme.cornerRadius)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack {
            Button(action: { showNewMemo.toggle() }) {
                HStack(spacing: 4) {
                    Image(systemName: showNewMemo ? "xmark" : "plus")
                        .font(.system(size: 11))
                    Text(showNewMemo ? "닫기" : "새 메모")
                        .font(.system(size: 12))
                }
                .foregroundColor(AppTheme.accent)
            }
            .buttonStyle(.plain)

            Spacer()

            Text("\(viewModel.filteredMemos.count)개 메모")
                .font(.system(size: 11))
                .foregroundColor(AppTheme.textTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppTheme.border.opacity(0.5))
    }

    private func resetNewMemo() {
        newTitle = ""
        newContent = ""
        showNewMemo = false
    }
}
