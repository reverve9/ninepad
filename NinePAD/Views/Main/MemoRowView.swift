import SwiftUI

struct MemoRowView: View {
    let memo: Memo
    var onTap: () -> Void
    var onDelete: () -> Void
    var onTogglePin: () -> Void

    @State private var isHovering = false
    @State private var showDeleteConfirm = false

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
                // 컬러 도트 (핀이면 pin 아이콘)
                if memo.isPinned {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 8))
                        .foregroundColor(AppTheme.accent)
                        .frame(width: 8)
                } else {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 8, height: 8)
                }

                // 타이틀 + 미리보기 + 날짜
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(memo.title.isEmpty ? "제목 없음" : memo.title)
                            .font(.system(size: 13, weight: memo.isPinned ? .semibold : .medium))
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

                // hover 시 액션
                if isHovering {
                    Button(action: { onTogglePin() }) {
                        Image(systemName: memo.isPinned ? "pin.slash" : "pin")
                            .font(.system(size: 9))
                            .foregroundColor(memo.isPinned ? AppTheme.textTertiary : AppTheme.accent)
                    }
                    .buttonStyle(.plain)
                    .help(memo.isPinned ? "핀 해제" : "핀 고정")

                    Button(action: { showDeleteConfirm = true }) {
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
        .alert("노트 삭제", isPresented: $showDeleteConfirm) {
            Button("휴지통으로 이동", role: .destructive) { onDelete() }
            Button("취소", role: .cancel) {}
        } message: {
            Text("이 노트를 휴지통으로 이동하시겠습니까?\n설정에서 복원할 수 있습니다.")
        }
    }
}
