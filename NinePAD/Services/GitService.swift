import Foundation

final class GitService {
    enum GitError: LocalizedError {
        case noRepoURL
        case noToken
        case cloneFailed(String)
        case pushFailed(String)

        var errorDescription: String? {
            switch self {
            case .noRepoURL: return "Git 레포 URL이 설정되지 않았습니다."
            case .noToken: return "GitHub Personal Access Token이 설정되지 않았습니다."
            case .cloneFailed(let msg): return "Clone 실패: \(msg)"
            case .pushFailed(let msg): return "Push 실패: \(msg)"
            }
        }
    }

    // MARK: - Keychain Keys

    private static let repoURLKey = "git_repo_url"
    private static let tokenKey = "git_token"

    // MARK: - Settings

    static var repoURL: String? {
        get { KeychainHelper.load(key: repoURLKey) }
        set {
            if let value = newValue {
                _ = KeychainHelper.save(key: repoURLKey, value: value)
            } else {
                KeychainHelper.delete(key: repoURLKey)
            }
        }
    }

    static var token: String? {
        get { KeychainHelper.load(key: tokenKey) }
        set {
            if let value = newValue {
                _ = KeychainHelper.save(key: tokenKey, value: value)
            } else {
                KeychainHelper.delete(key: tokenKey)
            }
        }
    }

    // MARK: - Markdown Conversion

    static func memoToMarkdown(_ memo: Memo) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        return """
        ---
        title: \(memo.title)
        date: \(dateFormatter.string(from: memo.createdAt))
        updated: \(dateFormatter.string(from: memo.updatedAt))
        ---

        \(memo.content)
        """
    }

    static func markdownFileName(_ title: String) -> String {
        let sanitized = title
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "\\", with: "_")
        return sanitized.isEmpty ? "untitled.md" : "\(sanitized).md"
    }

    // MARK: - Push Single Memo

    static func pushMemo(_ memo: Memo) async throws {
        guard let repoURL = repoURL, !repoURL.isEmpty else { throw GitError.noRepoURL }
        guard let token = token, !token.isEmpty else { throw GitError.noToken }

        let tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("ninepad-git-\(UUID().uuidString)")

        defer {
            try? FileManager.default.removeItem(at: tmpDir)
        }

        // Clone
        let authURL = authenticatedURL(repoURL, token: token)
        let cloneResult = try shell("git clone --depth 1 \(authURL) \(tmpDir.path)")
        if cloneResult.exitCode != 0 {
            throw GitError.cloneFailed(cloneResult.stderr)
        }

        // Write markdown
        let fileName = markdownFileName(memo.title)
        let filePath = tmpDir.appendingPathComponent(fileName)
        let markdown = memoToMarkdown(memo)
        try markdown.write(to: filePath, atomically: true, encoding: .utf8)

        // Git add, commit, push
        let commands = [
            "cd \(tmpDir.path) && git add .",
            "cd \(tmpDir.path) && git commit -m \"Update: \(memo.title)\"",
            "cd \(tmpDir.path) && git push origin HEAD"
        ]

        for cmd in commands {
            let result = try shell(cmd)
            if result.exitCode != 0 && !result.stderr.contains("nothing to commit") {
                throw GitError.pushFailed(result.stderr)
            }
        }
    }

    // MARK: - Push All Memos

    static func pushAllMemos(_ memos: [Memo]) async throws {
        guard let repoURL = repoURL, !repoURL.isEmpty else { throw GitError.noRepoURL }
        guard let token = token, !token.isEmpty else { throw GitError.noToken }

        let tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("ninepad-git-\(UUID().uuidString)")

        defer {
            try? FileManager.default.removeItem(at: tmpDir)
        }

        let authURL = authenticatedURL(repoURL, token: token)
        let cloneResult = try shell("git clone --depth 1 \(authURL) \(tmpDir.path)")
        if cloneResult.exitCode != 0 {
            throw GitError.cloneFailed(cloneResult.stderr)
        }

        // Write all memos
        for memo in memos {
            let fileName = markdownFileName(memo.title)
            let filePath = tmpDir.appendingPathComponent(fileName)
            let markdown = memoToMarkdown(memo)
            try markdown.write(to: filePath, atomically: true, encoding: .utf8)
        }

        let commands = [
            "cd \(tmpDir.path) && git add .",
            "cd \(tmpDir.path) && git commit -m \"Update: \(memos.count) memos\"",
            "cd \(tmpDir.path) && git push origin HEAD"
        ]

        for cmd in commands {
            let result = try shell(cmd)
            if result.exitCode != 0 && !result.stderr.contains("nothing to commit") {
                throw GitError.pushFailed(result.stderr)
            }
        }
    }

    // MARK: - Test Connection

    static func testConnection() async throws -> Bool {
        guard let repoURL = repoURL, !repoURL.isEmpty else { throw GitError.noRepoURL }
        guard let token = token, !token.isEmpty else { throw GitError.noToken }

        let authURL = authenticatedURL(repoURL, token: token)
        let result = try shell("git ls-remote \(authURL) HEAD")
        return result.exitCode == 0
    }

    // MARK: - Helpers

    private static func authenticatedURL(_ url: String, token: String) -> String {
        // https://github.com/user/repo.git → https://token@github.com/user/repo.git
        if url.hasPrefix("https://") {
            return url.replacingOccurrences(of: "https://", with: "https://\(token)@")
        }
        return url
    }

    private static func shell(_ command: String) throws -> (exitCode: Int32, stdout: String, stderr: String) {
        let process = Process()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        try process.run()
        process.waitUntilExit()

        let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()

        return (
            process.terminationStatus,
            String(data: stdoutData, encoding: .utf8) ?? "",
            String(data: stderrData, encoding: .utf8) ?? ""
        )
    }
}
