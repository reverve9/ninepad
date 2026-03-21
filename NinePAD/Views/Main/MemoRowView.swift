import SwiftUI

struct MemoRowView: View {
    let memo: MemoItem
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title Row (클릭으로 토글)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(AppTheme.textTertiary)
                        .frame(width: 12)

                    Text(memo.title)
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)

                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Content (펼침 상태)
            if isExpanded {
                Text(memo.content)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textSecondary)
                    .lineSpacing(4)
                    .padding(.horizontal, 28) // 12(icon) + 8(padding) + 8(indent)
                    .padding(.bottom, 10)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isExpanded ? AppTheme.hoverBg : Color.clear)
        )
    }
}
