import SwiftUI

struct SnippetZoneView: View {
    @ObservedObject var viewModel: SnippetViewModel
    @State private var copiedId: UUID?
    @State private var isHoveringId: UUID?
    @State private var editingId: UUID?
    @State private var editTitle = ""
    @State private var editContent = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Zone Label
            HStack {
                Text("SNIPPETS")
                    .font(.system(size: AppTheme.zoneLabelSize, weight: AppTheme.zoneLabelWeight))
                    .foregroundColor(AppTheme.zoneLabel)

                Spacer()

                if viewModel.isLoading {
                    ProgressView()
                        .controlSize(.mini)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)

            // Error
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.caption2)
                    .foregroundColor(AppTheme.danger)
                    .padding(.horizontal, 16)
            }

            // Snippet List
            if viewModel.snippets.isEmpty {
                Text("스니펫이 없습니다")
                    .font(.caption)
                    .foregroundColor(AppTheme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else {
                ForEach(viewModel.snippets) { snippet in
                    if editingId == snippet.id {
                        editRow(snippet)
                    } else {
                        snippetRow(snippet)
                    }
                }
            }
        }
        .padding(.bottom, 8)
        .background(AppTheme.snippetZoneBg)
    }

    // MARK: - Snippet Row

    @ViewBuilder
    private func snippetRow(_ snippet: Snippet) -> some View {
        HStack(spacing: 6) {
            Text(snippet.title)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)

            Spacer()

            // Hover 시 편집/삭제
            if isHoveringId == snippet.id {
                Button(action: { startEditing(snippet) }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.textTertiary)
                }
                .buttonStyle(.plain)

                Button(action: {
                    Task { await viewModel.deleteSnippet(id: snippet.id) }
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.danger.opacity(0.7))
                }
                .buttonStyle(.plain)
            }

            // 복사 버튼
            Button(action: {
                copyToClipboard(snippet)
            }) {
                Text(copiedId == snippet.id ? "복사됨" : "복사")
                    .font(.system(size: 11))
                    .foregroundColor(copiedId == snippet.id ? AppTheme.success : AppTheme.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(AppTheme.hoverBg.opacity(0.01))
        .contentShape(Rectangle())
        .onHover { hovering in
            isHoveringId = hovering ? snippet.id : nil
        }
    }

    // MARK: - Edit Row

    @ViewBuilder
    private func editRow(_ snippet: Snippet) -> some View {
        VStack(spacing: 6) {
            TextField("제목", text: $editTitle)
                .textFieldStyle(.plain)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)

            TextField("내용", text: $editContent)
                .textFieldStyle(.plain)
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)

            HStack {
                Button("취소") {
                    editingId = nil
                }
                .buttonStyle(.plain)
                .foregroundColor(AppTheme.textTertiary)
                .font(.system(size: 11))

                Spacer()

                Button("저장") {
                    Task {
                        await viewModel.updateSnippet(id: snippet.id, title: editTitle, content: editContent)
                        editingId = nil
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(AppTheme.accent)
                .font(.system(size: 11, weight: .medium))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppTheme.inputBg)
        .cornerRadius(6)
        .padding(.horizontal, 8)
    }

    // MARK: - Helpers

    private func startEditing(_ snippet: Snippet) {
        editTitle = snippet.title
        editContent = snippet.content
        editingId = snippet.id
    }

    private func copyToClipboard(_ snippet: Snippet) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(snippet.content, forType: .string)

        withAnimation(.easeInOut(duration: 0.15)) {
            copiedId = snippet.id
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.15)) {
                if copiedId == snippet.id {
                    copiedId = nil
                }
            }
        }
    }
}
