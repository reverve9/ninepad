import SwiftUI

struct MemoRowView: View {
    let memo: Memo
    var onTap: () -> Void
    var onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                // 메모 아이콘
                Image(systemName: "doc.text")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textTertiary)

                // 타이틀 + 미리보기
                VStack(alignment: .leading, spacing: 2) {
                    Text(memo.title.isEmpty ? "제목 없음" : memo.title)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(memo.title.isEmpty ? AppTheme.textTertiary : AppTheme.textPrimary)
                        .lineLimit(1)

                    Text(memo.content.isEmpty ? "내용 없음" : memo.content)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textTertiary)
                        .lineLimit(1)
                }

                Spacer()

                // 삭제 (hover 시)
                if isHovering {
                    Button(action: { onDelete() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .buttonStyle(.plain)
                }

                // 화살표
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textTertiary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isHovering ? AppTheme.hoverBg : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
