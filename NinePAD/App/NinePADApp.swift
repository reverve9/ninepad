import SwiftUI
import Carbon.HIToolbox

@main
struct NinePADApp: App {
    @StateObject private var authService = AuthService()
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra(AppConfig.appName, systemImage: "note.text") {
            ContentView()
                .environmentObject(authService)
        }
        .menuBarExtraStyle(.window)
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

        // 이벤트 핸들러 등록
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, _) -> OSStatus in
                // MenuBarExtra 토글: 메뉴바 아이콘 클릭 시뮬레이션
                if let button = NSApp.windows.first(where: {
                    $0.className.contains("StatusBar") || $0.className.contains("MenuBarExtra")
                }) {
                    if NSApp.windows.contains(where: {
                        $0.isVisible && $0.className.contains("MenuBarExtra") && !$0.className.contains("StatusBar")
                    }) {
                        // 팝오버가 열려있으면 닫기
                        NSApp.windows.filter {
                            $0.isVisible && $0.className.contains("MenuBarExtra") && !$0.className.contains("StatusBar")
                        }.forEach { $0.orderOut(nil) }
                    } else {
                        // 팝오버 열기
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
