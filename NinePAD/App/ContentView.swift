import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.openWindow) var openWindow

    var body: some View {
        if authService.currentSession != nil {
            VStack(spacing: 0) {
                // 상단 계정 표시
                accountBar

                MainView()
            }
            .frame(width: AppTheme.popoverWidth)
            .frame(maxHeight: AppTheme.popoverMaxHeight)
            .background(AppTheme.popoverBg)
        } else {
            // 비로그인 시 팝오버에서 로그인 Window 오픈 유도
            VStack(spacing: 12) {
                Text("로그인이 필요합니다")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.textSecondary)

                Button("로그인 창 열기") {
                    openWindow(id: "login")
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(width: AppTheme.popoverWidth, height: 120)
            .background(AppTheme.popoverBg)
        }
    }

    private var accountBar: some View {
        HStack {
            if let user = authService.currentUser {
                Text(user.email)
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textTertiary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(AppTheme.popoverBg)
    }
}
