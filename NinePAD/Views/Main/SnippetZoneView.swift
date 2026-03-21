import SwiftUI

struct SnippetZoneView: View {
    // Phase 4에서 Supabase 연동 예정, 지금은 목업 데이터
    @State private var snippets: [SnippetItem] = SnippetItem.mockData
    @State private var copiedId: UUID?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Zone Label
            Text("SNIPPETS")
                .font(.system(size: AppTheme.zoneLabelSize, weight: AppTheme.zoneLabelWeight))
                .foregroundColor(AppTheme.zoneLabel)
                .padding(.horizontal, 16)
                .padding(.top, 12)

            // Snippet List
            if snippets.isEmpty {
                Text("스니펫이 없습니다")
                    .font(.caption)
                    .foregroundColor(AppTheme.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            } else {
                ForEach(snippets) { snippet in
                    snippetRow(snippet)
                }
            }
        }
        .padding(.bottom, 8)
        .background(AppTheme.snippetZoneBg)
    }

    @ViewBuilder
    private func snippetRow(_ snippet: SnippetItem) -> some View {
        HStack {
            Text(snippet.title)
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textPrimary)
                .lineLimit(1)

            Spacer()

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
        .background(AppTheme.hoverBg.opacity(0.01)) // 히트 영역 확보
        .contentShape(Rectangle())
    }

    private func copyToClipboard(_ snippet: SnippetItem) {
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

// MARK: - Mock Data (Phase 4에서 제거)

struct SnippetItem: Identifiable {
    let id: UUID
    let title: String
    let content: String

    static let mockData: [SnippetItem] = [
        .init(id: UUID(), title: "SSH 접속 명령어", content: "ssh user@192.168.1.100"),
        .init(id: UUID(), title: "Git force push", content: "git push --force-with-lease origin main"),
        .init(id: UUID(), title: "Docker 재시작", content: "docker compose down && docker compose up -d"),
    ]
}
