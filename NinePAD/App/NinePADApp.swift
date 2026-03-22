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
                .onOpenURL { url in
                    handleInviteURL(url)
                }
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
        .windowResizability(.contentSize)
        .defaultPosition(.center)

        // 메뉴바 아이콘 (클릭 시 메인 Window 토글)
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

// MARK: - Menu Bar Content (간단한 메뉴)

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
                Text(user.email)
                    .foregroundColor(.secondary)

                if user.isSuperAdmin {
                    Text("Super Admin")
                        .foregroundColor(.secondary)
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

        Button("종료") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}

// MARK: - Login Window View

struct LoginWindowView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.openWindow) var openWindow

    var body: some View {
        VStack(spacing: 0) {
            LoginView()
                .environmentObject(authService)
        }
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

// MARK: - AppDelegate (글로벌 단축키)

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var hotKeyRef: EventHotKeyRef?

    func applicationDidFinishLaunching(_ notification: Notification) {
        registerGlobalHotKey()
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
                // 메인 Window 토글
                if let mainWindow = NSApp.windows.first(where: { $0.identifier?.rawValue == "main" || $0.title == "NinePAD" }) {
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
