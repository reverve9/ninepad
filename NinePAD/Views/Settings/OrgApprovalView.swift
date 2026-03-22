import SwiftUI

struct OrgApprovalView: View {
    @EnvironmentObject var authService: AuthService
    @State private var pendingOrgs: [Organization] = []
    @State private var orgAdmins: [UUID: AppUser] = [:]
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let orgService = OrgService()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("ORG 승인 관리")
                    .font(.system(size: AppTheme.zoneLabelSize, weight: .medium))
                    .foregroundColor(AppTheme.textTertiary)

                Spacer()

                if isLoading {
                    ProgressView().controlSize(.mini)
                }

                Button(action: { Task { await loadData() } }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }

            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.danger)
            }

            if pendingOrgs.isEmpty {
                Text("대기 중인 Org 신청이 없습니다.")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textTertiary)
                    .padding(.vertical, 8)
            } else {
                ForEach(pendingOrgs) { org in
                    orgRequestRow(org)
                }
            }
        }
        .padding(16)
        .task { await loadData() }
    }

    @ViewBuilder
    private func orgRequestRow(_ org: Organization) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(org.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppTheme.textPrimary)

                    if let admin = orgAdmins[org.id] {
                        Text(admin.email)
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textSecondary)
                    }

                    Text(org.createdAt.formatted(.dateTime.month().day().hour().minute()))
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.textTertiary)
                }

                Spacer()

                // 승인
                Button(action: {
                    Task { await approve(org) }
                }) {
                    Text("승인")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppTheme.success)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)

                // 거절
                Button(action: {
                    Task { await reject(org) }
                }) {
                    Text("거절")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(AppTheme.danger)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(AppTheme.inputBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Actions

    private func loadData() async {
        isLoading = true
        errorMessage = nil
        do {
            pendingOrgs = try await orgService.fetchPendingOrgs()
            for org in pendingOrgs {
                if let admin = try? await orgService.fetchOrgAdmin(orgId: org.id) {
                    orgAdmins[org.id] = admin
                }
            }
        } catch {
            errorMessage = "로드 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }

    private func approve(_ org: Organization) async {
        do {
            _ = try await orgService.approveOrg(orgId: org.id)
            pendingOrgs.removeAll { $0.id == org.id }
        } catch {
            errorMessage = "승인 실패: \(error.localizedDescription)"
        }
    }

    private func reject(_ org: Organization) async {
        do {
            _ = try await orgService.rejectOrg(orgId: org.id)
            pendingOrgs.removeAll { $0.id == org.id }
        } catch {
            errorMessage = "거절 실패: \(error.localizedDescription)"
        }
    }
}
