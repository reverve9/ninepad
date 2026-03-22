import SwiftUI

enum AppTheme {
    // MARK: - Backgrounds
    static let snippetZoneBg = Color(hex: 0xF7F8FA)
    static let memoZoneBg    = Color(hex: 0xFFFFFF)
    static let popoverBg     = Color(hex: 0xFFFFFF)
    static let inputBg       = Color(hex: 0xF2F3F5)
    static let hoverBg       = Color.black.opacity(0.04)

    // MARK: - Text
    static let textPrimary   = Color(hex: 0x1C2B4A)
    static let textSecondary = Color(hex: 0x5A5A6A)
    static let textTertiary  = Color(hex: 0x8A8A8E)
    static let zoneLabel     = Color(hex: 0x8A8A8E)
    static let placeholder   = Color(hex: 0xC0C0C6)

    // MARK: - Accent
    static let accent        = Color(hex: 0x1C2B4A)
    static let accentLight   = Color(hex: 0xE8EBF2)
    static let accentHover   = Color(hex: 0x15213A)
    static let success       = Color(hex: 0x34C759)
    static let warning       = Color(hex: 0xF5A623)
    static let danger        = Color(hex: 0xEF4444)

    // MARK: - Border
    static let border        = Color.black.opacity(0.08)
    static let borderSub     = Color.black.opacity(0.04)
    static let borderActive  = Color(hex: 0x1C2B4A)

    // MARK: - Sizes
    static let popoverWidth: CGFloat = 340
    static let popoverMaxHeight: CGFloat = 600
    static let cornerRadius: CGFloat = 10
    static let zoneLabelSize: CGFloat = 10
    static let zoneLabelWeight: Font.Weight = .light

    // MARK: - Login
    static let loginWidth: CGFloat = 400
    static let loginHeight: CGFloat = 540
    static let fieldHeight: CGFloat = 44
    static let buttonHeight: CGFloat = 48

    // MARK: - Main
    static let mainWidth: CGFloat = 380
    static let mainHeight: CGFloat = 520

    // MARK: - Memo Detail
    static let memoWidth: CGFloat = 360
    static let memoHeight: CGFloat = 420
}

// MARK: - Color Hex Extension

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}
