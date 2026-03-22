import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var selectedTab: AuthTab = .login

    enum AuthTab {
        case login, signup
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
                .padding(.top, 40)
                .padding(.bottom, 28)

            // Tab Bar
            tabBar
                .padding(.horizontal, 32)

            // Content
            Group {
                switch selectedTab {
                case .login:
                    loginForm
                case .signup:
                    SignUpView(onBack: { selectedTab = .login })
                }
            }
            .padding(.horizontal, 32)
            .padding(.top, 24)

            Spacer()

            // Footer
            Text("© 2024 Nineworx. All rights reserved.")
                .font(.system(size: 11))
                .foregroundColor(AppTheme.placeholder)
                .padding(.bottom, 16)
        }
        .frame(width: AppTheme.loginWidth, height: AppTheme.loginHeight)
        .background(AppTheme.popoverBg)
        .onAppear {
            if authService.pendingInviteToken != nil {
                selectedTab = .signup
            }
        }
        .onChange(of: authService.pendingInviteToken) { _, token in
            if token != nil {
                selectedTab = .signup
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "note.text.badge.plus")
                .font(.system(size: 32, weight: .thin))
                .foregroundColor(AppTheme.accent)
                .frame(width: 56, height: 56)
                .background(AppTheme.accentLight)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(AppConfig.appName)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(AppTheme.textPrimary)

            Text("개인 메모 & 스니펫")
                .font(.system(size: 14))
                .foregroundColor(AppTheme.textTertiary)
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton("로그인", tab: .login)
            tabButton("회원가입", tab: .signup)
        }
    }

    private func tabButton(_ title: String, tab: AuthTab) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: selectedTab == tab ? .semibold : .regular))
                    .foregroundColor(selectedTab == tab ? AppTheme.textPrimary : AppTheme.textTertiary)

                Rectangle()
                    .fill(selectedTab == tab ? AppTheme.accent : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Login Form

    @State private var email = ""
    @State private var password = ""

    private var loginForm: some View {
        VStack(spacing: 16) {
            NinePADField(label: "이메일", placeholder: "이메일 주소 입력", text: $email)
            NinePADField(label: "비밀번호", placeholder: "비밀번호 입력", text: $password, isSecure: true)

            if let error = authService.errorMessage {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.danger)
                    .multilineTextAlignment(.center)
            }

            NinePADButton(title: "로그인", isLoading: authService.isLoading) {
                Task { await authService.login(email: email, password: password) }
            }
            .disabled(email.isEmpty || password.isEmpty || authService.isLoading)
        }
    }
}

// MARK: - Reusable Components

struct NinePADField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .textFieldStyle(.plain)
            .font(.system(size: 14))
            .foregroundColor(AppTheme.textPrimary)
            .padding(.horizontal, 16)
            .frame(height: AppTheme.fieldHeight)
            .background(AppTheme.inputBg)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                    .stroke(isFocused ? AppTheme.borderActive : Color.clear, lineWidth: 0.5)
            )
            .focused($isFocused)
        }
    }
}

struct NinePADButton: View {
    let title: String
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(.white)
                } else {
                    Text(title)
                        .font(.system(size: 15, weight: .medium))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: AppTheme.buttonHeight)
            .background(AppTheme.accent)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        }
        .buttonStyle(.plain)
    }
}
