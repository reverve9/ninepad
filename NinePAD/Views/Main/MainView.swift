import SwiftUI

struct MainView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var snippetViewModel = SnippetViewModel()

    var body: some View {
        VStack(spacing: 0) {
            SnippetZoneView(viewModel: snippetViewModel)

            Divider()
                .background(AppTheme.border)

            MemoZoneView(snippetViewModel: snippetViewModel)
        }
        .onAppear {
            if let user = authService.currentUser, let orgId = user.orgId {
                snippetViewModel.setup(userId: user.id, orgId: orgId)
            }
        }
        .onDisappear {
            Task { await snippetViewModel.stopRealtime() }
        }
    }
}
