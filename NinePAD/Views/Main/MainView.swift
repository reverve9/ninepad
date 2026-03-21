import SwiftUI

struct MainView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        VStack(spacing: 0) {
            SnippetZoneView()

            Divider()
                .background(AppTheme.border)

            MemoZoneView()
        }
    }
}
