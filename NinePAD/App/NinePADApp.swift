import SwiftUI

@main
struct NinePADApp: App {
    @StateObject private var authService = AuthService()

    var body: some Scene {
        MenuBarExtra(AppConfig.appName, systemImage: "note.text") {
            ContentView()
                .environmentObject(authService)
        }
        .menuBarExtraStyle(.window)
    }
}
