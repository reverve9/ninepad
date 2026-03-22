import SwiftUI
import Carbon.HIToolbox

@main
struct NinePADApp: App {
    @StateObject private var authService = AuthService()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // 로그인 Window
        Window("NinePAD", id: "login") {
            LoginWindowView()
                .environmentObject(authService)
                .onOpenURL { url in handleInviteURL(url) }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        // 메인 Window
        Window("NinePAD", id: "main") {
            MainWindowView()
                .environmentObject(authService)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 380, height: 520)
        .defaultPosition(.center)

        // 메모 상세 Window (독립 창)
        WindowGroup("메모", for: UUID.self) { $memoId in
            if let memoId {
                MemoWindowView(memoId: memoId)
                    .environmentObject(authService)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .defaultSize(width: 360, height: 420)
        .defaultPosition(.center)

        // 메뉴바
        MenuBarExtra(AppConfig.appName, systemImage: "note.text") {
            MenuBarContentView()
                .environmentObject(authService)
        }
        .menuBarExtraStyle(.menu)
    }

    private func handleInviteURL(_ url: URL) {
        guard url.scheme == "ninepad",
              url.host == "invite",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let token = components.queryItems?.first(where: { $0.name == "token" })?.value
        else { return }
        authService.pendingInviteToken = token
    }
}

// MARK: - Menu Bar Content

struct MenuBarContentView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.openWindow) var openWindow

    var body: some View {
        if authService.currentSession != nil {
            Button("NinePAD 열기") {
                openWindow(id: "main")
                NSApp.activate(ignoringOtherApps: true)
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])

            Divider()

            if let user = authService.currentUser {
                Text(user.email).foregroundColor(.secondary)
                if user.isSuperAdmin {
                    Text("Super Admin").foregroundColor(.secondary)
                }
            }

            Divider()

            Button("로그아웃") {
                Task {
                    await authService.logout()
                    openWindow(id: "login")
                }
            }
        } else {
            Button("로그인") {
                openWindow(id: "login")
                NSApp.activate(ignoringOtherApps: true)
            }
        }

        Divider()
        Button("종료") { NSApplication.shared.terminate(nil) }
            .keyboardShortcut("q")
    }
}

// MARK: - Login Window View

struct LoginWindowView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.openWindow) var openWindow

    var body: some View {
        LoginView()
            .environmentObject(authService)
            .frame(width: AppTheme.loginWidth, height: AppTheme.loginHeight)
            .background(AppTheme.popoverBg)
            .onChange(of: authService.currentSession != nil) { _, isLoggedIn in
                if isLoggedIn {
                    dismissWindow(id: "login")
                    openWindow(id: "main")
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
            .onAppear {
                if authService.currentSession != nil {
                    dismissWindow(id: "login")
                }
            }
    }
}

// MARK: - Main Window View

struct MainWindowView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.openWindow) var openWindow

    var body: some View {
        ContentView()
            .environmentObject(authService)
            .onAppear {
                if authService.currentSession == nil {
                    openWindow(id: "login")
                }
            }
            .onChange(of: authService.currentSession == nil) { _, isLoggedOut in
                if isLoggedOut {
                    openWindow(id: "login")
                }
            }
    }
}

// MARK: - Memo Window View (독립 창 — 기존 노트 / 새 노트)

struct MemoWindowView: View {
    @EnvironmentObject var authService: AuthService
    let memoId: UUID  // 새 노트일 경우 더미 UUID
    @State private var memo: Memo?
    @State private var isLoading = true
    @State private var isNewNote = false

    private let memoService = MemoService()

    var body: some View {
        Group {
            if isNewNote {
                MemoDetailView(
                    memo: nil,
                    onSave: { title, content, colorDot in
                        Task { await createNote(title: title, content: content, colorDot: colorDot) }
                    }
                )
            } else if let memo {
                MemoDetailView(
                    memo: memo,
                    onSave: { _, _, _ in },
                    onUpdate: { title, content in
                        Task {
                            let updated = try? await memoService.updateMemo(id: memo.id, title: title, content: content)
                            if let updated { self.memo = updated }
                        }
                    },
                    onDelete: {
                        Task { try? await memoService.deleteMemo(id: memo.id) }
                    },
                    onPinToSnippet: {
                        if let user = authService.currentUser, let orgId = user.orgId {
                            Task {
                                _ = try? await SnippetService().createSnippet(
                                    userId: user.id, orgId: orgId, title: memo.title, content: memo.content
                                )
                            }
                        }
                    },
                    onPush: {
                        Task { try? await GitService.pushMemo(memo) }
                    }
                )
            } else if isLoading {
                VStack {
                    ProgressView()
                    Text("로딩 중...")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.textTertiary)
                }
                .frame(minWidth: AppTheme.memoWidth, minHeight: AppTheme.memoHeight)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppTheme.popoverBg)
            }
        }
        .task { await loadMemo() }
    }

    private func loadMemo() async {
        // 새 노트용 더미 UUID 체크 (00000000-...)
        if memoId == MemoWindowHelper.newNoteId {
            isNewNote = true
            isLoading = false
            return
        }
        guard let user = authService.currentUser, let orgId = user.orgId else { return }
        do {
            let memos = try await memoService.fetchMemos(orgId: orgId)
            memo = memos.first { $0.id == memoId }
        } catch {
            print("[Note] 로드 실패: \(error)")
        }
        isLoading = false
    }

    private func createNote(title: String, content: String, colorDot: String) async {
        guard let user = authService.currentUser, let orgId = user.orgId else { return }
        do {
            let newMemo = try await memoService.createMemo(userId: user.id, orgId: orgId, title: title, content: content)
            self.memo = newMemo
            isNewNote = false
        } catch {
            print("[Note] 생성 실패: \(error)")
        }
    }
}

// 새 노트 구분용 헬퍼
enum MemoWindowHelper {
    static let newNoteId = UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
}

// MARK: - AppDelegate (글로벌 단축키)

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var hotKeyRef: EventHotKeyRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        registerGlobalHotKey()
        disableFocusRing()
    }

    private func disableFocusRing() {
        // 전역 포커스링 해제 — NSView 서브클래스 swizzling
        let original = class_getInstanceMethod(NSView.self, #selector(getter: NSView.focusRingType))!
        let replacement = class_getInstanceMethod(NSView.self, #selector(NSView.ninepad_focusRingType))!
        method_exchangeImplementations(original, replacement)
    }

    private func registerGlobalHotKey() {
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x4E504144)
        hotKeyID.id = 1

        let modifiers: UInt32 = UInt32(cmdKey | shiftKey)
        let keyCode: UInt32 = UInt32(kVK_ANSI_N)

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, _) -> OSStatus in
                if let mainWindow = NSApp.windows.first(where: { $0.title == "NinePAD" && !$0.className.contains("StatusBar") }) {
                    if mainWindow.isVisible {
                        mainWindow.orderOut(nil)
                    } else {
                        mainWindow.makeKeyAndOrderFront(nil)
                        NSApp.activate(ignoringOtherApps: true)
                    }
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            nil
        )

        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
    }
}

// MARK: - Focus Ring 전역 해제

extension NSView {
    @objc func ninepad_focusRingType() -> NSFocusRingType {
        return .none
    }
}
