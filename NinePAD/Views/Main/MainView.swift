import SwiftUI

struct MainView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var snippetViewModel = SnippetViewModel()
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 0) {
            // 스니펫 존
            SnippetZoneView(viewModel: snippetViewModel)

            Divider().background(AppTheme.border)

            // 메모 존
            MemoZoneView(snippetViewModel: snippetViewModel)

            Divider().background(AppTheme.border)

            // 하단 툴바
            bottomToolbar
        }
        .onAppear {
            if let user = authService.currentUser, let orgId = user.orgId {
                snippetViewModel.setup(userId: user.id, orgId: orgId)
            }
        }
        .onDisappear {
            Task { await snippetViewModel.stopRealtime() }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(authService)
        }
    }

    private var bottomToolbar: some View {
        HStack {
            Spacer()

            Button(action: { showSettings = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 12))
                    Text("설정")
                        .font(.system(size: 11))
                }
                .foregroundColor(AppTheme.textTertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(AppTheme.popoverBg)
    }
}
