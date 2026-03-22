import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @State private var orgStatus: OrgStatus?
    @State private var isCheckingStatus = false

    private let orgService = OrgService()

    var body: some View {
        VStack(spacing: 0) {
            // 상단 앱 바
            appBar

            Divider().background(AppTheme.border)

            // 메인 콘텐츠
            Group {
                if authService.currentUser == nil {
                    loadingView
                } else if authService.currentUser!.isSuperAdmin && authService.currentUser!.orgId == nil {
                    superAdminSetupView
                } else if authService.currentUser!.isSuperAdmin {
                    MainView()
                } else if orgStatus == .approved {
                    MainView()
                } else if orgStatus == .pending {
                    pendingView
                } else if orgStatus == .rejected {
                    rejectedView
                } else {
                    loadingView
                        .task { await checkOrgStatus() }
                }
            }
        }
        .frame(minWidth: AppTheme.mainWidth, minHeight: AppTheme.mainHeight)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.popoverBg)
        .onChange(of: authService.currentUser?.id) { _, _ in
            Task { await checkOrgStatus() }
        }
    }

    // MARK: - App Bar

    private var appBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "note.text.badge.plus")
                .font(.system(size: 16, weight: .thin))
                .foregroundColor(AppTheme.accent)

            Text(AppConfig.appName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)

            Spacer()

            if let user = authService.currentUser {
                Text(user.email)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textTertiary)
                    .lineLimit(1)

                if user.isSuperAdmin {
                    Text("SA")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(AppTheme.danger)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(AppTheme.popoverBg)
    }

    // MARK: - Pending

    private var pendingView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 36, weight: .thin))
                .foregroundColor(AppTheme.warning)

            Text("Org 승인 대기 중")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)

            Text("슈퍼 관리자의 승인을 기다리고 있습니다.\n승인 후 자동으로 활성화됩니다.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            Button("새로고침") {
                Task { await checkOrgStatus() }
            }
            .buttonStyle(.plain)
            .font(.system(size: 13))
            .foregroundColor(AppTheme.accent)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Rejected

    private var rejectedView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "xmark.circle")
                .font(.system(size: 36, weight: .thin))
                .foregroundColor(AppTheme.danger)

            Text("Org 신청이 거절되었습니다")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)

            Text("관리자에게 문의해주세요.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Super Admin Setup

    @State private var newOrgName = ""
    @State private var isCreatingOrg = false

    private var superAdminSetupView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "building.2")
                .font(.system(size: 36, weight: .thin))
                .foregroundColor(AppTheme.accent)

            Text("내 Org 만들기")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)

            Text("노트와 스니펫을 사용하려면\nOrg가 필요합니다.")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            NinePADField(label: "조직 이름", placeholder: "예: Nineworx", text: $newOrgName)
                .padding(.horizontal, 60)

            NinePADButton(title: isCreatingOrg ? "생성 중..." : "Org 생성", isLoading: isCreatingOrg) {
                Task { await createOrgForSuperAdmin() }
            }
            .disabled(newOrgName.isEmpty || isCreatingOrg)
            .padding(.horizontal, 60)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func createOrgForSuperAdmin() async {
        guard let user = authService.currentUser else { return }
        let client = SupabaseManager.shared.client
        isCreatingOrg = true
        do {
            // Org 생성 (approved 상태)
            let org: Organization = try await client.from("organizations")
                .insert(["name": newOrgName, "status": "approved"])
                .select()
                .single()
                .execute()
                .value

            // 슈퍼어드민의 org_id 업데이트
            let updated: AppUser = try await client.from("users")
                .update(["org_id": org.id.uuidString])
                .eq("id", value: user.id.uuidString)
                .select()
                .single()
                .execute()
                .value

            authService.currentUser = updated
            orgStatus = .approved
        } catch {
            authService.errorMessage = "Org 생성 실패: \(error.localizedDescription)"
        }
        isCreatingOrg = false
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 8) {
            Spacer()
            ProgressView()
            Text("로딩 중...")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textTertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Check Org Status

    private func checkOrgStatus() async {
        guard let user = authService.currentUser else { return }
        if user.isSuperAdmin && user.orgId != nil {
            orgStatus = .approved
            return
        }
        if user.isSuperAdmin && user.orgId == nil {
            // Org 없는 슈퍼어드민 → setup 화면
            orgStatus = nil
            return
        }
        guard let orgId = user.orgId else {
            orgStatus = nil
            return
        }
        isCheckingStatus = true
        do {
            let org = try await orgService.fetchOrganization(orgId: orgId)
            orgStatus = org.status
        } catch {
            orgStatus = nil
        }
        isCheckingStatus = false
    }
}
