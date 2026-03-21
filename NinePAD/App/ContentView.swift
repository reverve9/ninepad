import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        Group {
            if authService.currentSession != nil {
                LoggedInView()
            } else {
                LoginView()
            }
        }
        .frame(width: 320, height: 400)
    }
}

// MARK: - Logged In (Placeholder for Phase 2)

struct LoggedInView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)

            Text("환영합니다!")
                .font(.title2.bold())

            if let user = authService.currentUser {
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("역할: \(user.role.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button("로그아웃") {
                Task { await authService.logout() }
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)

            Spacer()
        }
        .padding()
    }
}
