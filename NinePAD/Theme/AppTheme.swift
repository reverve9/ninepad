import SwiftUI

enum AppTheme {
    // MARK: - Backgrounds
    static let snippetZoneBg = Color(hex: 0x19202E)
    static let memoZoneBg    = Color(hex: 0x1E2535)
    static let popoverBg     = Color(hex: 0x141A26)
    static let inputBg       = Color(hex: 0x252D3D)
    static let hoverBg       = Color.white.opacity(0.05)

    // MARK: - Text
    static let textPrimary   = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let textTertiary  = Color.white.opacity(0.4)
    static let zoneLabel     = Color.white.opacity(0.25)

    // MARK: - Accent
    static let accent        = Color(hex: 0x4A9EFF)
    static let accentHover   = Color(hex: 0x6BB3FF)
    static let success       = Color(hex: 0x34D399)
    static let danger        = Color(hex: 0xEF4444)

    // MARK: - Border
    static let border        = Color.white.opacity(0.08)
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
