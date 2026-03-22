import SwiftUI

struct MemoDetailView: View {
    let memo: Memo?  // nil이면 새 노트
    var onSave: (String, String, String) -> Void  // title, content, colorDot
    var onUpdate: ((String, String) -> Void)?
    var onDelete: (() -> Void)?
    var onPinToSnippet: (() -> Void)?
    var onPush: (() -> Void)?

    @State private var isEditing: Bool
    @State private var editTitle: String
    @State private var editContent: String
    @State private var selectedColor: String
    @State private var showDeleteConfirm = false

    private let dotColors = ["#1C2B4A", "#EF4444", "#F5A623", "#34C759", "#4EB8FA", "#8B5CF6"]

    init(
        memo: Memo?,
        onSave: @escaping (String, String, String) -> Void,
        onUpdate: ((String, String) -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        onPinToSnippet: (() -> Void)? = nil,
        onPush: (() -> Void)? = nil
    ) {
        self.memo = memo
        self.onSave = onSave
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        self.onPinToSnippet = onPinToSnippet
        self.onPush = onPush
        // 새 노트면 바로 편집 모드
        _isEditing = State(initialValue: memo == nil)
        _editTitle = State(initialValue: memo?.title ?? "")
        _editContent = State(initialValue: memo?.content ?? "")
        _selectedColor = State(initialValue: memo?.colorDot ?? "#1C2B4A")
    }

    private var isNewNote: Bool { memo == nil }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Divider().background(AppTheme.border)

            if isEditing {
                editView
            } else {
                readView
            }
        }
        .frame(minWidth: AppTheme.memoWidth, minHeight: AppTheme.memoHeight)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.popoverBg)
    }

    // MARK: - Toolbar

    private var toolbar: some View {
        HStack(spacing: 8) {
            // 컬러 도트
            if isEditing {
                ForEach(dotColors, id: \.self) { hex in
                    let val = UInt(hex.replacingOccurrences(of: "#", with: ""), radix: 16) ?? 0
                    Circle()
                        .fill(Color(hex: val))
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(Color.black.opacity(selectedColor == hex ? 0.3 : 0), lineWidth: 1.5))
                        .onTapGesture { selectedColor = hex }
                }
            } else {
                let val = UInt((memo?.colorDot ?? "#1C2B4A").replacingOccurrences(of: "#", with: ""), radix: 16) ?? 0
                Circle()
                    .fill(Color(hex: val))
                    .frame(width: 8, height: 8)
            }

            // 제목
            if isEditing {
                TextField("제목 입력", text: $editTitle)
                    .textFieldStyle(.plain)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            } else {
                Text(memo?.title ?? "")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
                    .lineLimit(1)
            }

            Spacer()

            if isEditing {
                Button(action: {
                    if isNewNote {
                        // 새 노트에서 취소 → 창 닫기 (사용자가 수동)
                    } else {
                        isEditing = false
                    }
                }) {
                    Text("취소")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textTertiary)
                }
                .buttonStyle(.plain)

                Button(action: save) {
                    Text(isNewNote ? "생성" : "저장")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(editTitle.isEmpty ? AppTheme.textTertiary : AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .disabled(editTitle.isEmpty)
            } else {
                if let onPinToSnippet {
                    Button(action: onPinToSnippet) {
                        Image(systemName: "pin")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .help("스니펫으로 올리기")
                }

                if let onPush {
                    Button(action: onPush) {
                        Image(systemName: "arrow.up.to.line")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .help("Git 푸시")
                }

                Button(action: startEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textTertiary)
                }
                .buttonStyle(.plain)
                .help("편집")

                if let onDelete {
                    Button(action: { showDeleteConfirm = true }) {
                        Image(systemName: "trash")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.danger.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    .help("삭제")
                    .alert("노트 삭제", isPresented: $showDeleteConfirm) {
                        Button("삭제", role: .destructive) { onDelete() }
                        Button("취소", role: .cancel) {}
                    } message: {
                        Text("이 노트를 삭제하시겠습니까?")
                    }
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
            VStack(alignment: .leading, spacing: 8) {
                if let memo, !memo.content.isEmpty {
                    Text(memo.content)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineSpacing(6)
                        .textSelection(.enabled)
                } else {
                    Text("내용이 없습니다.")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textTertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.inputBg.opacity(0.3))
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
            .background(AppTheme.inputBg.opacity(0.3))
    }

    // MARK: - Actions

    private func startEdit() {
        editTitle = memo?.title ?? ""
        editContent = memo?.content ?? ""
        selectedColor = memo?.colorDot ?? "#1C2B4A"
        isEditing = true
    }

    private func save() {
        if isNewNote {
            onSave(editTitle, editContent, selectedColor)
        } else {
            onUpdate?(editTitle, editContent)
        }
        isEditing = false
    }
}
