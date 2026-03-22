import SwiftUI

struct MemoDetailView: View {
    let memo: Memo
    var onUpdate: (String, String) -> Void
    var onDelete: () -> Void
    var onPinToSnippet: () -> Void
    var onPush: () -> Void

    @State private var isEditing = false
    @State private var editTitle: String = ""
    @State private var editContent: String = ""
    @State private var showDeleteConfirm = false

    var body: some View {
        VStack(spacing: 0) {
            // 상단 툴바
            toolbar

            Divider().background(AppTheme.border)

            // 콘텐츠
            if isEditing {
                editView
            } else {
                readView
            }
        }
        .frame(width: AppTheme.memoWidth, height: AppTheme.memoHeight)
        .background(AppTheme.popoverBg)
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack(spacing: 8) {
            // 제목
            if isEditing {
                TextField("제목", text: $editTitle)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            } else {
                Text(memo.title.isEmpty ? "제목 없음" : memo.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(memo.title.isEmpty ? AppTheme.textTertiary : AppTheme.textPrimary)
                    .lineLimit(1)
            }

            Spacer()

            if isEditing {
                Button(action: cancelEdit) {
                    Text("취소")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textTertiary)
                }
                .buttonStyle(.plain)

                Button(action: saveEdit) {
                    Text("저장")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            } else {
                // 스니펫으로 올리기
                Button(action: { onPinToSnippet() }) {
                    Image(systemName: "pin")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textTertiary)
                }
                .buttonStyle(.plain)
                .help("스니펫으로 올리기")

                // Git 푸시
                Button(action: { onPush() }) {
                    Image(systemName: "arrow.up.to.line")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textTertiary)
                }
                .buttonStyle(.plain)
                .help("Git 푸시")

                // 편집
                Button(action: startEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textTertiary)
                }
                .buttonStyle(.plain)
                .help("편집")

                // 삭제
                Button(action: { showDeleteConfirm = true }) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.danger.opacity(0.7))
                }
                .buttonStyle(.plain)
                .help("삭제")
                .alert("메모 삭제", isPresented: $showDeleteConfirm) {
                    Button("삭제", role: .destructive) { onDelete() }
                    Button("취소", role: .cancel) {}
                } message: {
                    Text("이 메모를 삭제하시겠습니까?")
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppTheme.popoverBg)
    }

    // MARK: - Read View

    private var readView: some View {
        ScrollView {
            Text(memo.content.isEmpty ? "내용이 없습니다." : memo.content)
                .font(.system(size: 13))
                .foregroundColor(memo.content.isEmpty ? AppTheme.textTertiary : AppTheme.textPrimary)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.inputBg.opacity(0.5))
    }

    // MARK: - Edit View

    private var editView: some View {
        TextEditor(text: $editContent)
            .font(.system(size: 13))
            .foregroundColor(AppTheme.textPrimary)
            .lineSpacing(6)
            .scrollContentBackground(.hidden)
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.inputBg.opacity(0.5))
    }

    // MARK: - Actions

    private func startEdit() {
        editTitle = memo.title
        editContent = memo.content
        isEditing = true
    }

    private func cancelEdit() {
        isEditing = false
    }

    private func saveEdit() {
        onUpdate(editTitle, editContent)
        isEditing = false
    }
}
