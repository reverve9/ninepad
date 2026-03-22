import Foundation

enum AppConfig {
    // MARK: - Supabase
    static let supabaseURL = "https://ujfjduravztyssnaewxb.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqZmpkdXJhdnp0eXNzbmFld3hiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQxMDAzNTQsImV4cCI6MjA4OTY3NjM1NH0.Re596f7Qke0FIdKoETfGm8XFv2NmkyMCiFRQGgpi8YI"

    // MARK: - Dev
    /// 개발 모드: true면 초대 없이 바로 가입 가능
    #if DEBUG
    static let devMode = true
    #else
    static let devMode = false
    #endif

    // MARK: - App
    static let appName = "NinePAD"
    static let bundleID = "com.ninepad.NinePAD"
}
