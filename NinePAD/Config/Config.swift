import Foundation

enum AppConfig {
    // MARK: - Supabase
    static let supabaseURL = "https://ujfjduravztyssnaewxb.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqZmpkdXJhdnp0eXNzbmFld3hiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQxMDAzNTQsImV4cCI6MjA4OTY3NjM1NH0.Re596f7Qke0FIdKoETfGm8XFv2NmkyMCiFRQGgpi8YI"

    // MARK: - Admin
    /// 관리자 인증코드 — Org 생성 시 이 코드를 입력해야 함
    /// 프로덕션에서는 환경변수 또는 서버사이드 검증으로 대체 권장
    static let adminInviteCode = "NINEPAD-ADMIN-2026"

    // MARK: - App
    static let appName = "NinePAD"
    static let bundleID = "com.ninepad.NinePAD"
}
