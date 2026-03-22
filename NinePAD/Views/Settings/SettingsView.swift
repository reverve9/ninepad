import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService

    private var isAdmin: Bool {
        authService.currentUser?.isAdmin ?? false
    }

    private var isSuperAdmin: Bool {
        authService.currentUser?.isSuperAdmin ?? false
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ProfileView()

                Divider().background(AppTheme.border)

                // 슈퍼어드민: Org 승인 관리
                if isSuperAdmin {
                    OrgApprovalView()

                    Divider().background(AppTheme.border)
                }

                // admin: Org 설정
                if isAdmin && !isSuperAdmin {
                    OrgSettingsView()
                } else if !isSuperAdmin {
                    memberOrgInfo
                }

                Divider().background(AppTheme.border)

                TrashView()

                Divider().background(AppTheme.border)

                GitSettingsView()
            }
        }
        .frame(maxWidth: 340, maxHeight: 500)
        .background(AppTheme.popoverBg)
    }

    private var memberOrgInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ORG INFO")
                .font(.system(size: AppTheme.zoneLabelSize, weight: AppTheme.zoneLabelWeight))
                .foregroundColor(AppTheme.zoneLabel)

            Text("Org 관리는 관리자만 가능합니다.")
                .font(.system(size: 12))
                .foregroundColor(AppTheme.textTertiary)
        }
        .padding(16)
    }
}
