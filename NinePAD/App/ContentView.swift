import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.openWindow) var openWindow
    @State private var orgStatus: OrgStatus?
    @State private var isCheckingStatus = false

    private let orgService = OrgService()

    var body: some View {
        Group {
            if authService.currentSession == nil {
                notLoggedInView
            } else if authService.currentUser == nil {
                loadingView
            } else if authService.currentUser!.isSuperAdmin {
                loggedInContent
            } else if orgStatus == .approved {
                loggedInContent
            } else if orgStatus == .pending {
                pendingView
            } else if orgStatus == .rejected {
                rejectedView
            } else if isCheckingStatus {
                loadingView
            } else {
                // orgStatus가 nil이고 체크도 끝남 → 다시 체크
                loadingView
                    .task { await checkOrgStatus() }
            }
        }
        .onChange(of: authService.currentUser?.id) { _, _ in
            Task { await checkOrgStatus() }
        }
    }

    // MARK: - Logged In

    private var loggedInContent: some View {
        VStack(spacing: 0) {
            accountBar
            MainView()
        }
        .frame(width: AppTheme.popoverWidth)
        .frame(maxHeight: AppTheme.popoverMaxHeight)
        .background(AppTheme.popoverBg)
    }

    // MARK: - Pending

    private var pendingView: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 32, weight: .thin))
                .foregroundColor(AppTheme.warning)

            Text("Org 승인 대기 중")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)

            Text("슈퍼 관리자의 승인을 기다리고 있습니다.\n승인 후 자동으로 활성화됩니다.")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)

            Button("새로고침") {
                Task { await checkOrgStatus() }
            }
            .buttonStyle(.plain)
            .font(.system(size: 12))
            .foregroundColor(AppTheme.accent)
            .padding(.top, 4)
        }
        .frame(width: AppTheme.popoverWidth, height: 200)
        .background(AppTheme.popoverBg)
    }

    // MARK: - Rejected

    private var rejectedView: some View {
        VStack(spacing: 12) {
            Image(systemName: "xmark.circle")
                .font(.system(size: 32, weight: .thin))
                .foregroundColor(AppTheme.danger)

            Text("Org 신청이 거절되었습니다")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(AppTheme.textPrimary)

            Text("관리자에게 문의해주세요.")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(width: AppTheme.popoverWidth, height: 180)
        .background(AppTheme.popoverBg)
    }

    // MARK: - Not Logged In

    private var notLoggedInView: some View {
        VStack(spacing: 12) {
            Text("로그인이 필요합니다")
                .font(.system(size: 13))
                .foregroundColor(AppTheme.textSecondary)

            Button("로그인 창 열기") {
                openWindow(id: "login")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(width: AppTheme.popoverWidth, height: 120)
        .background(AppTheme.popoverBg)
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("로딩 중...")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textTertiary)
        }
        .frame(width: AppTheme.popoverWidth, height: 120)
        .background(AppTheme.popoverBg)
    }

    // MARK: - Account Bar

    private var accountBar: some View {
        HStack {
            if let user = authService.currentUser {
                Text(user.email)
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.textTertiary)
                    .lineLimit(1)

                if user.isSuperAdmin {
                    Text("SA")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(AppTheme.danger)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(AppTheme.popoverBg)
    }

    // MARK: - Check Org Status

    private func checkOrgStatus() async {
        guard let user = authService.currentUser else { return }
        if user.isSuperAdmin {
            orgStatus = .approved
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
