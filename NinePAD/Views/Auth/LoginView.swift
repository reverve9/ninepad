import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false

    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 4) {
                Image(systemName: "note.text")
                    .font(.system(size: 36))
                    .foregroundColor(.accentColor)
                Text(AppConfig.appName)
                    .font(.title2.bold())
                Text("로그인")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 24)

            Spacer()

            // Form
            VStack(spacing: 12) {
                TextField("이메일", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)

                SecureField("비밀번호", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
            }
            .padding(.horizontal)

            // Error
            if let error = authService.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            // Login Button
            Button(action: {
                Task { await authService.login(email: email, password: password) }
            }) {
                if authService.isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("로그인")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(email.isEmpty || password.isEmpty || authService.isLoading)
            .padding(.horizontal)

            Spacer()

            // Sign Up Link
            Divider()
            Button("계정이 없으신가요? 회원가입") {
                showSignUp = true
            }
            .buttonStyle(.plain)
            .foregroundColor(.accentColor)
            .font(.caption)
            .padding(.bottom, 12)
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView()
                .environmentObject(authService)
        }
        .onAppear {
            if authService.pendingInviteToken != nil {
                showSignUp = true
            }
        }
        .onChange(of: authService.pendingInviteToken) { token in
            if token != nil {
                showSignUp = true
            }
        }
    }
}
