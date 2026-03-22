import SwiftUI

struct OrgSettingsView: View {
    @EnvironmentObject var authService: AuthService

    @State private var members: [AppUser] = []
    @State private var invitations: [Invitation] = []
    @State private var orgName = ""
    @State private var inviteEmail = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var copiedToken: String?

    private let orgService = OrgService()
    private let invitationService = InvitationService()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Org Header
            Text("ORG SETTINGS")
                .font(.system(size: AppTheme.zoneLabelSize, weight: AppTheme.zoneLabelWeight))
                .foregroundColor(AppTheme.zoneLabel)

            if !orgName.isEmpty {
                Text(orgName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(AppTheme.textPrimary)
            }

            // Error
            if let error = errorMessage {
                Text(error)
                    .font(.caption2)
                    .foregroundColor(AppTheme.danger)
            }

            Divider().background(AppTheme.border)

            // Members
            membersSection

            Divider().background(AppTheme.border)

            // Invitations
            invitationsSection
        }
        .padding(16)
        .task { await loadData() }
    }

    // MARK: - Members Section

    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("멤버")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)

            ForEach(members) { member in
                HStack {
                    Text(member.email)
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textPrimary)
                        .lineLimit(1)

                    Spacer()

                    // 역할 배지
                    Text(member.role.rawValue)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(member.role == .admin ? AppTheme.accent : AppTheme.textTertiary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill((member.role == .admin ? AppTheme.accent : AppTheme.textTertiary).opacity(0.15))
                        )

                    // 역할 변경 (본인 제외)
                    if member.id != authService.currentUser?.id {
                        Button(action: {
                            Task { await toggleRole(member) }
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.textTertiary)
                        }
                        .buttonStyle(.plain)
                        .help("역할 변경")

                        // 제거
                        Button(action: {
                            Task { await removeMember(member) }
                        }) {
                            Image(systemName: "xmark.circle")
                                .font(.system(size: 10))
                                .foregroundColor(AppTheme.danger.opacity(0.7))
                        }
                        .buttonStyle(.plain)
                        .help("멤버 제거")
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Invitations Section

    private var invitationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("초대")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)

            // 새 초대
            HStack(spacing: 8) {
                TextField("이메일 주소", text: $inviteEmail)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(AppTheme.inputBg)
                    .cornerRadius(6)

                Button(action: {
                    Task { await createInvite() }
                }) {
                    Text("초대")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(inviteEmail.isEmpty ? AppTheme.textTertiary : AppTheme.accent)
                }
                .buttonStyle(.plain)
                .disabled(inviteEmail.isEmpty || isLoading)
            }

            // 대기 중인 초대
            ForEach(invitations.filter { $0.acceptedAt == nil }) { invitation in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(invitation.email)
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.textPrimary)

                        Text("만료: \(invitation.expiresAt.formatted(.dateTime.month().day().hour().minute()))")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.textTertiary)
                    }

                    Spacer()

                    // 링크 복사
                    Button(action: {
                        copyInviteLink(invitation.token)
                    }) {
                        Text(copiedToken == invitation.token ? "복사됨" : "링크 복사")
                            .font(.system(size: 10))
                            .foregroundColor(copiedToken == invitation.token ? AppTheme.success : AppTheme.accent)
                    }
                    .buttonStyle(.plain)

                    // 취소
                    Button(action: {
                        Task { await revokeInvite(invitation) }
                    }) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.danger.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 4)
            }

            if invitations.filter({ $0.acceptedAt == nil }).isEmpty {
                Text("대기 중인 초대가 없습니다")
                    .font(.caption)
                    .foregroundColor(AppTheme.textTertiary)
            }
        }
    }

    // MARK: - Actions

    private func loadData() async {
        guard let user = authService.currentUser, let orgId = user.orgId else { return }
        isLoading = true
        do {
            let org = try await orgService.fetchOrganization(orgId: orgId)
            orgName = org.name
            members = try await orgService.fetchMembers(orgId: orgId)
            invitations = try await invitationService.fetchInvitations(orgId: orgId)
        } catch {
            errorMessage = "데이터 로드 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }

    private func toggleRole(_ member: AppUser) async {
        let newRole: UserRole = member.role == .admin ? .member : .admin
        do {
            let updated = try await orgService.updateMemberRole(userId: member.id, role: newRole)
            if let index = members.firstIndex(where: { $0.id == member.id }) {
                members[index] = updated
            }
        } catch {
            errorMessage = "역할 변경 실패: \(error.localizedDescription)"
        }
    }

    private func removeMember(_ member: AppUser) async {
        do {
            try await orgService.removeMember(userId: member.id)
            members.removeAll { $0.id == member.id }
        } catch {
            errorMessage = "멤버 제거 실패: \(error.localizedDescription)"
        }
    }

    private func createInvite() async {
        guard let user = authService.currentUser else { return }
        isLoading = true
        do {
            guard let orgId = user.orgId else { return }
            let invitation = try await invitationService.createInvitation(orgId: orgId, email: inviteEmail)
            invitations.insert(invitation, at: 0)
            inviteEmail = ""
        } catch {
            errorMessage = "초대 생성 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }

    private func revokeInvite(_ invitation: Invitation) async {
        do {
            try await invitationService.revokeInvitation(id: invitation.id)
            invitations.removeAll { $0.id == invitation.id }
        } catch {
            errorMessage = "초대 취소 실패: \(error.localizedDescription)"
        }
    }

    private func copyInviteLink(_ token: String) {
        let link = "ninepad://invite?token=\(token)"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(link, forType: .string)

        withAnimation { copiedToken = token }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                if copiedToken == token { copiedToken = nil }
            }
        }
    }
}
