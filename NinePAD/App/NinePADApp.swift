import SwiftUI
import Carbon.HIToolbox

@main
struct NinePADApp: App {
    @StateObject private var authService = AuthService()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // 로그인 Window (비로그인 시 자동 오픈)
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

        // 메뉴바 팝오버 (로그인 후)
        MenuBarExtra(AppConfig.appName, systemImage: "note.text") {
            ContentView()
                .environmentObject(authService)
        }
        .menuBarExtraStyle(.window)
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

// MARK: - Login Window View

struct LoginWindowView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismissWindow) var dismissWindow

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
            }
        }
        .onAppear {
            if authService.currentSession != nil {
                dismissWindow(id: "login")
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
        // Cmd+Shift+N
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(0x4E504144) // "NPAD"
        hotKeyID.id = 1

        let modifiers: UInt32 = UInt32(cmdKey | shiftKey)
        let keyCode: UInt32 = UInt32(kVK_ANSI_N)

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, _) -> OSStatus in
                if let button = NSApp.windows.first(where: {
                    $0.className.contains("StatusBar") || $0.className.contains("MenuBarExtra")
                }) {
                    if NSApp.windows.contains(where: {
                        $0.isVisible && $0.className.contains("MenuBarExtra") && !$0.className.contains("StatusBar")
                    }) {
                        NSApp.windows.filter {
                            $0.isVisible && $0.className.contains("MenuBarExtra") && !$0.className.contains("StatusBar")
                        }.forEach { $0.orderOut(nil) }
                    } else {
                        button.makeKeyAndOrderFront(nil)
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
