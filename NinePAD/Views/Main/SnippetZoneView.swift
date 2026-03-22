import SwiftUI

struct SnippetZoneView: View {
    @ObservedObject var viewModel: SnippetViewModel
    @State private var copiedId: UUID?
    @State private var isHoveringId: UUID?

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
                    snippetRow(snippet)
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

            // Hover 시 삭제
            if isHoveringId == snippet.id {
                Button(action: {
                    Task { await viewModel.deleteSnippet(id: snippet.id) }
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.textTertiary)
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

    // MARK: - Helpers

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
