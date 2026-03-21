import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        Group {
            if authService.currentSession != nil {
                MainView()
            } else {
                LoginView()
            }
        }
        .frame(width: AppTheme.popoverWidth)
        .frame(maxHeight: AppTheme.popoverMaxHeight)
        .background(AppTheme.popoverBg)
    }
}
