import SwiftUI

struct GitSettingsView: View {
    @State private var repoURL: String = GitService.repoURL ?? ""
    @State private var token: String = GitService.token ?? ""
    @State private var testResult: TestResult?
    @State private var isTesting = false

    enum TestResult {
        case success, failure(String)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("GIT SETTINGS")
                .font(.system(size: AppTheme.zoneLabelSize, weight: AppTheme.zoneLabelWeight))
                .foregroundColor(AppTheme.zoneLabel)

            // Repo URL
            VStack(alignment: .leading, spacing: 4) {
                Text("레포 URL")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textSecondary)

                TextField("https://github.com/user/repo.git", text: $repoURL)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(AppTheme.inputBg)
                    .cornerRadius(6)
                    .onChange(of: repoURL) { newValue in
                        GitService.repoURL = newValue.isEmpty ? nil : newValue
                    }
            }

            // Token
            VStack(alignment: .leading, spacing: 4) {
                Text("Personal Access Token")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.textSecondary)

                SecureField("ghp_...", text: $token)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(AppTheme.inputBg)
                    .cornerRadius(6)
                    .onChange(of: token) { newValue in
                        GitService.token = newValue.isEmpty ? nil : newValue
                    }
            }

            // Test Connection
            HStack {
                Button(action: testConnection) {
                    HStack(spacing: 4) {
                        if isTesting {
                            ProgressView()
                                .controlSize(.mini)
                        } else {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.system(size: 11))
                        }
                        Text("연결 테스트")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(AppTheme.accent)
                }
                .buttonStyle(.plain)
                .disabled(repoURL.isEmpty || token.isEmpty || isTesting)

                Spacer()

                if let result = testResult {
                    switch result {
                    case .success:
                        Text("연결 성공")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.success)
                    case .failure(let msg):
                        Text(msg)
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.danger)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(16)
    }

    private func testConnection() {
        isTesting = true
        testResult = nil
        Task {
            do {
                let ok = try await GitService.testConnection()
                testResult = ok ? .success : .failure("연결 실패")
            } catch {
                testResult = .failure(error.localizedDescription)
            }
            isTesting = false
        }
    }
}
