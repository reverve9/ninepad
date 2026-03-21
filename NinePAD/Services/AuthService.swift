import Foundation
import Supabase
import Auth

final class AuthService: ObservableObject {
    private let client = SupabaseManager.shared.client

    @Published var currentSession: Session?
    @Published var currentUser: AppUser?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init() {
        Task { await restoreSession() }
    }

    // MARK: - Session

    @MainActor
    func restoreSession() async {
        do {
            let session = try await client.auth.session
            self.currentSession = session
            await fetchUserProfile(userId: session.user.id)
        } catch {
            self.currentSession = nil
        }
    }

    // MARK: - Login

    @MainActor
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )
            self.currentSession = session
            await fetchUserProfile(userId: session.user.id)
        } catch {
            errorMessage = "로그인 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - Sign Up (Admin — creates Org)

    @MainActor
    func signUpAsAdmin(email: String, password: String, orgName: String, adminCode: String) async {
        isLoading = true
        errorMessage = nil

        guard adminCode == AppConfig.adminInviteCode else {
            errorMessage = "관리자 인증코드가 올바르지 않습니다."
            isLoading = false
            return
        }

        do {
            // 1. Supabase Auth에 사용자 등록
            let authResponse = try await client.auth.signUp(
                email: email,
                password: password
            )
            guard let userId = authResponse.session?.user.id else {
                errorMessage = "회원가입 후 세션을 가져올 수 없습니다."
                isLoading = false
                return
            }

            // 2. Organization 생성
            let org = try await client.from("organizations")
                .insert(["name": orgName])
                .select()
                .single()
                .execute()
                .value as Organization

            // 3. users 테이블에 admin으로 등록
            let newUser = try await client.from("users")
                .insert([
                    "id": userId.uuidString,
                    "org_id": org.id.uuidString,
                    "email": email,
                    "role": "admin"
                ])
                .select()
                .single()
                .execute()
                .value as AppUser

            self.currentSession = authResponse.session
            self.currentUser = newUser
        } catch {
            errorMessage = "관리자 가입 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - Sign Up (Member — dev mode, org 이름으로 직접 참여)

    @MainActor
    func signUpAsMember(email: String, password: String, orgName: String) async {
        isLoading = true
        errorMessage = nil

        guard AppConfig.devMode else {
            errorMessage = "개발 모드에서만 사용 가능합니다."
            isLoading = false
            return
        }

        do {
            // 1. org 이름으로 조직 조회
            let org: Organization = try await client.from("organizations")
                .select()
                .eq("name", value: orgName)
                .single()
                .execute()
                .value

            // 2. Supabase Auth 등록
            let authResponse = try await client.auth.signUp(
                email: email,
                password: password
            )
            guard let userId = authResponse.session?.user.id else {
                errorMessage = "회원가입 후 세션을 가져올 수 없습니다."
                isLoading = false
                return
            }

            // 3. users 테이블에 member로 등록
            let newUser = try await client.from("users")
                .insert([
                    "id": userId.uuidString,
                    "org_id": org.id.uuidString,
                    "email": email,
                    "role": "member"
                ])
                .select()
                .single()
                .execute()
                .value as AppUser

            self.currentSession = authResponse.session
            self.currentUser = newUser
        } catch {
            errorMessage = "멤버 가입 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - Sign Up (Member — via invite token)

    @MainActor
    func signUpWithInvite(email: String, password: String, inviteToken: String) async {
        isLoading = true
        errorMessage = nil

        do {
            // 1. 초대 토큰 검증
            let invitation: Invitation = try await client.from("invitations")
                .select()
                .eq("token", value: inviteToken)
                .eq("email", value: email)
                .is("accepted_at", value: "null")
                .gt("expires_at", value: ISO8601DateFormatter().string(from: Date()))
                .single()
                .execute()
                .value

            // 2. Supabase Auth 등록
            let authResponse = try await client.auth.signUp(
                email: email,
                password: password
            )
            guard let userId = authResponse.session?.user.id else {
                errorMessage = "회원가입 후 세션을 가져올 수 없습니다."
                isLoading = false
                return
            }

            // 3. users 테이블에 member로 등록
            let newUser = try await client.from("users")
                .insert([
                    "id": userId.uuidString,
                    "org_id": invitation.orgId.uuidString,
                    "email": email,
                    "role": "member"
                ])
                .select()
                .single()
                .execute()
                .value as AppUser

            // 4. 초대 수락 처리
            try await client.from("invitations")
                .update(["accepted_at": ISO8601DateFormatter().string(from: Date())])
                .eq("id", value: invitation.id.uuidString)
                .execute()

            self.currentSession = authResponse.session
            self.currentUser = newUser
        } catch {
            errorMessage = "초대 가입 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - Logout

    @MainActor
    func logout() async {
        do {
            try await client.auth.signOut()
            currentSession = nil
            currentUser = nil
        } catch {
            errorMessage = "로그아웃 실패: \(error.localizedDescription)"
        }
    }

    // MARK: - Profile

    @MainActor
    private func fetchUserProfile(userId: UUID) async {
        do {
            let user: AppUser = try await client.from("users")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            self.currentUser = user
        } catch {
            errorMessage = "프로필 로드 실패: \(error.localizedDescription)"
        }
    }
}
