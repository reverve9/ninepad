import SwiftUI

enum AppTheme {
    // MARK: - Backgrounds
    static let snippetZoneBg = Color(hex: 0x252526)
    static let memoZoneBg    = Color(hex: 0x1E1E1E)
    static let popoverBg     = Color(hex: 0x1E1E1E)
    static let inputBg       = Color(hex: 0x2D2D2D)
    static let hoverBg       = Color.white.opacity(0.05)

    // MARK: - Text
    static let textPrimary   = Color(hex: 0xD4D4D4)
    static let textSecondary = Color(hex: 0x9D9D9D)
    static let textTertiary  = Color(hex: 0x5A5A5A)
    static let zoneLabel     = Color(hex: 0x5A5A5A)

    // MARK: - Accent
    static let accent        = Color(hex: 0x4EB8FA)
    static let accentHover   = Color(hex: 0x6BC8FF)
    static let success       = Color(hex: 0x57A64A)
    static let warning       = Color(hex: 0xCDA869)
    static let danger        = Color(hex: 0xEF4444)

    // MARK: - Border
    static let border        = Color.white.opacity(0.08)
    static let borderSub     = Color.white.opacity(0.04)
    static let borderActive  = Color.white.opacity(0.15)

    // MARK: - Sizes
    static let popoverWidth: CGFloat = 340
    static let popoverMaxHeight: CGFloat = 600
    static let cornerRadius: CGFloat = 8
    static let zoneLabelSize: CGFloat = 10
    static let zoneLabelWeight: Font.Weight = .light
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
