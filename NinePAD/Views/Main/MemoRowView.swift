import SwiftUI

struct MemoRowView: View {
    let memo: Memo
    var onUpdate: (String, String) -> Void
    var onDelete: () -> Void

    @State private var isExpanded = false
    @State private var isEditing = false
    @State private var editTitle: String = ""
    @State private var editContent: String = ""
    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title Row
            HStack {
                // 펼침/접힘 토글
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isExpanded.toggle()
                        if !isExpanded { isEditing = false }
                    }
                }) {
                    HStack {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(AppTheme.textTertiary)
                            .frame(width: 12)

                        Text(memo.title.isEmpty ? "제목 없음" : memo.title)
                            .font(.system(size: 13))
                            .foregroundColor(memo.title.isEmpty ? AppTheme.textTertiary : AppTheme.textPrimary)
                            .lineLimit(1)

                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // Hover 시 액션 버튼들
                if isHovering || isExpanded {
                    if !isEditing {
                        Button(action: { startEditing() }) {
                            Image(systemName: "pencil")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textTertiary)
                        }
                        .buttonStyle(.plain)
                    }

                    Button(action: { onDelete() }) {
                        Image(systemName: "trash")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.danger.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)

            // Content (펼침 상태)
            if isExpanded {
                if isEditing {
                    editForm
                } else {
                    Text(memo.content.isEmpty ? "내용 없음" : memo.content)
                        .font(.system(size: 12))
                        .foregroundColor(memo.content.isEmpty ? AppTheme.textTertiary : AppTheme.textSecondary)
                        .lineSpacing(4)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 10)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isExpanded ? AppTheme.hoverBg : Color.clear)
        )
        .onHover { hovering in
            isHovering = hovering
        }
    }

    // MARK: - Edit Form

    private var editForm: some View {
        VStack(spacing: 8) {
            TextField("제목", text: $editTitle)
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)

            TextEditor(text: $editContent)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 60, maxHeight: 120)

            HStack {
                Button("취소") {
                    isEditing = false
                }
                .buttonStyle(.plain)
                .foregroundColor(AppTheme.textTertiary)
                .font(.system(size: 12))

                Spacer()

                Button("저장") {
                    onUpdate(editTitle, editContent)
                    isEditing = false
                }
                .buttonStyle(.plain)
                .foregroundColor(AppTheme.accent)
                .font(.system(size: 12, weight: .medium))
            }
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 10)
        .transition(.opacity)
    }

    private func startEditing() {
        editTitle = memo.title
        editContent = memo.content
        isEditing = true
        if !isExpanded {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded = true
            }
        }
    }
}
