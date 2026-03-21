import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authService: AuthService

    private var isAdmin: Bool {
        authService.currentUser?.role == .admin
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ProfileView()

                Divider().background(AppTheme.border)

                if isAdmin {
                    OrgSettingsView()
                } else {
                    memberOrgInfo
                }
            }
        }
        .frame(width: 340, maxHeight: 500)
        .background(AppTheme.popoverBg)
    }

    // member 전용: org 정보만 표시
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
