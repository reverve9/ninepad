import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authService: AuthService
    var onBack: () -> Void

    @State private var email = ""
    @State private var password = ""
    @State private var passwordConfirm = ""

    // Admin
    @State private var orgName = ""
    @State private var adminCode = ""

    // Invite
    @State private var inviteToken = ""

    // Dev member
    @State private var orgCode = ""

    @State private var signUpMode: SignUpMode = .admin

    enum SignUpMode: String, CaseIterable {
        case admin = "관리자"
        case member = "멤버"
        case invite = "초대"

        static var availableCases: [SignUpMode] {
            AppConfig.devMode ? [.admin, .member, .invite] : [.admin, .invite]
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Mode Picker
            Picker("", selection: $signUpMode) {
                ForEach(SignUpMode.availableCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            // Common Fields
            NinePADField(label: "이메일", placeholder: "이메일 주소 입력", text: $email)
            NinePADField(label: "비밀번호", placeholder: "비밀번호 입력", text: $password, isSecure: true)
            NinePADField(label: "비밀번호 확인", placeholder: "비밀번호 재입력", text: $passwordConfirm, isSecure: true)

            // Mode-specific
            switch signUpMode {
            case .admin:
                NinePADField(label: "조직 이름", placeholder: "조직명 입력", text: $orgName)
                NinePADField(label: "관리자 인증코드", placeholder: "인증코드 입력", text: $adminCode, isSecure: true)
            case .member:
                NinePADField(label: "조직 이름", placeholder: "참여할 조직명 입력", text: $orgCode)
            case .invite:
                NinePADField(label: "초대 토큰", placeholder: "초대 토큰 입력", text: $inviteToken)
            }

            // Validation
            if !passwordConfirm.isEmpty && password != passwordConfirm {
                Text("비밀번호가 일치하지 않습니다.")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.warning)
            }

            // Error
            if let error = authService.errorMessage {
                Text(error)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.danger)
                    .multilineTextAlignment(.center)
            }

            // Sign Up Button
            NinePADButton(title: "가입하기", isLoading: authService.isLoading) {
                signUp()
            }
            .disabled(!isFormValid || authService.isLoading)
        }
        .interactiveDismissDisabled(authService.isLoading)
        .onAppear {
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
        }
    }
}
