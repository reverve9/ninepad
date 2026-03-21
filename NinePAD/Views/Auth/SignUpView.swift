import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authService: AuthService
    var onBack: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirm = ""

    // Admin signup
    @State private var orgName = ""
    @State private var adminCode = ""

    // Invite signup
    @State private var inviteToken = ""

    // Dev member signup (초대 없이 org 코드로 참여)
    @State private var orgCode = ""

    @State private var signUpMode: SignUpMode = .admin

    enum SignUpMode: String, CaseIterable {
        case admin = "관리자 (Org 생성)"
        case member = "멤버 (Org 참여)"
        case invite = "초대 링크 가입"

        static var availableCases: [SignUpMode] {
            if AppConfig.devMode {
                return [.admin, .member, .invite]
            } else {
                return [.admin, .invite]
            }
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Button("취소") { withAnimation(.easeInOut(duration: 0.2)) { onBack() } }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                Spacer()
                Text("회원가입")
                    .font(.headline)
                Spacer()
                // Balance spacer
                Button("취소") { }.hidden()
            }
            .padding(.horizontal)
            .padding(.top, 16)

            // Mode Picker
            Picker("가입 방식", selection: $signUpMode) {
                ForEach(SignUpMode.availableCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // Common fields
            VStack(spacing: 12) {
                TextField("이메일", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)

                SecureField("비밀번호", text: $password)
                    .textFieldStyle(.roundedBorder)

                SecureField("비밀번호 확인", text: $passwordConfirm)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal)

            // Mode-specific fields
            VStack(spacing: 12) {
                switch signUpMode {
                case .admin:
                    TextField("조직 이름", text: $orgName)
                        .textFieldStyle(.roundedBorder)
                    SecureField("관리자 인증코드", text: $adminCode)
                        .textFieldStyle(.roundedBorder)
                case .member:
                    TextField("조직 이름 (정확히 입력)", text: $orgCode)
                        .textFieldStyle(.roundedBorder)
                case .invite:
                    TextField("초대 토큰", text: $inviteToken)
                        .textFieldStyle(.roundedBorder)
                }
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

            // Password mismatch
            if !passwordConfirm.isEmpty && password != passwordConfirm {
                Text("비밀번호가 일치하지 않습니다.")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            Spacer()

            // Sign Up Button
            Button(action: signUp) {
                if authService.isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Text("가입하기")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!isFormValid || authService.isLoading)
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .frame(width: 320, height: 480)
        .interactiveDismissDisabled(authService.isLoading)
        .onAppear {
            // URL Scheme에서 초대 토큰이 전달된 경우 자동 설정
            if let token = authService.pendingInviteToken {
                signUpMode = .invite
                inviteToken = token
                authService.pendingInviteToken = nil
            }
        }
    }

    private var isFormValid: Bool {
        let commonValid = !email.isEmpty && !password.isEmpty && password == passwordConfirm && password.count >= 6
        switch signUpMode {
        case .admin:
            return commonValid && !orgName.isEmpty && !adminCode.isEmpty
        case .member:
            return commonValid && !orgCode.isEmpty
        case .invite:
            return commonValid && !inviteToken.isEmpty
        }
    }

    private func signUp() {
        Task {
            switch signUpMode {
            case .admin:
                await authService.signUpAsAdmin(
                    email: email,
                    password: password,
                    orgName: orgName,
                    adminCode: adminCode
                )
            case .member:
                await authService.signUpAsMember(
                    email: email,
                    password: password,
                    orgName: orgCode
                )
            case .invite:
                await authService.signUpWithInvite(
                    email: email,
                    password: password,
                    inviteToken: inviteToken
                )
            }
            // 가입 성공 시 ContentView가 자동으로 MainView로 전환
        }
    }
}
