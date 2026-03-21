import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PROFILE")
                .font(.system(size: AppTheme.zoneLabelSize, weight: AppTheme.zoneLabelWeight))
                .foregroundColor(AppTheme.zoneLabel)

            if let user = authService.currentUser {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.accent)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.email)
                            .font(.system(size: 13))
                            .foregroundColor(AppTheme.textPrimary)

                        HStack(spacing: 4) {
                            Text(user.role.rawValue.uppercased())
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(user.role == .admin ? AppTheme.accent : AppTheme.textTertiary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill((user.role == .admin ? AppTheme.accent : AppTheme.textTertiary).opacity(0.15))
                                )
                        }
                    }
                }

                Divider().background(AppTheme.border)

                Button(action: {
                    Task { await authService.logout() }
                }) {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 12))
                        Text("로그아웃")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(AppTheme.danger)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
    }
}
