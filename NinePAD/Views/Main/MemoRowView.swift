import SwiftUI

struct MemoRowView: View {
    let memo: Memo
    var onTap: () -> Void
    var onDelete: () -> Void

    @State private var isHovering = false

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M/d HH:mm"
        return f
    }()

    private var dotColor: Color {
        guard let hex = memo.colorDot, let val = UInt(hex.replacingOccurrences(of: "#", with: ""), radix: 16) else {
            return AppTheme.accent
        }
        return Color(hex: val)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                // 컬러 도트
                Circle()
                    .fill(dotColor)
                    .frame(width: 8, height: 8)

                // 타이틀 + 미리보기 + 날짜
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(memo.title.isEmpty ? "제목 없음" : memo.title)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(memo.title.isEmpty ? AppTheme.textTertiary : AppTheme.textPrimary)
                            .lineLimit(1)

                        Spacer()

                        Text(Self.dateFormatter.string(from: memo.createdAt))
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.placeholder)
                    }

                    Text(memo.content.isEmpty ? "내용 없음" : memo.content)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textTertiary)
                        .lineLimit(1)
                }

                // 삭제 (hover 시)
                if isHovering {
                    Button(action: { onDelete() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 9))
                            .foregroundColor(AppTheme.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
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
