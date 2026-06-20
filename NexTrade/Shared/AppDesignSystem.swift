import SwiftUI

enum AppColor {
    static let background = Color(light: 0xEEF1F5, dark: 0x0D1113)
    static let backgroundElevated = Color(light: 0xF6F8FB, dark: 0x151B1D)
    static let surface = Color(light: 0xFBFCFF, dark: 0x1A2023)
    static let primaryText = Color(light: 0x111827, dark: 0xF4F7F8)
    static let secondaryText = Color(light: 0x6B7280, dark: 0xA2ADB3)
    static let border = Color(light: 0xDEE4ED, dark: 0x273235)
    static let primaryAccent = Color(light: 0x5B4BDB, dark: 0xD8C7FF)
    static let accentDark = Color(light: 0x4338CA, dark: 0xA78BFA)
    static let accentChipFill = Color(light: 0xE9E4FF, dark: 0xA78BFA)
    static let onAccentChip = Color(light: 0x5B4BDB, dark: 0x191226)
    static let ink = Color(light: 0x0B1715, dark: 0xF4F7F8)
    static let inkMuted = Color(light: 0x9CA3AF, dark: 0x879298)
    static let softAccentBackground = Color(light: 0xE9E4FF, dark: 0x3B2A6F)
    static let glassStroke = Color(light: 0xFFFFFF, dark: 0x344145)
    static let heroGradientStart = Color(light: 0xFBFCFF, dark: 0x1B2225)
    static let heroGradientEnd = Color(light: 0xF0F4F8, dark: 0x111719)
    static let artworkStart = Color(light: 0xF7FAFF, dark: 0x20282C)
    static let artworkEnd = Color(light: 0xE7EDF5, dark: 0x13191C)
    static let processing = Color(light: 0xF59E0B, dark: 0xFBBF24)
    static let success = Color(light: 0x10B981, dark: 0x34D399)
    static let error = Color(light: 0xEF4444, dark: 0xF87171)
}

enum AppSpacing {
    static let xsmall: CGFloat = 6
    static let small: CGFloat = 10
    static let medium: CGFloat = 14
    static let large: CGFloat = 20
    static let xlarge: CGFloat = 28
}

enum AppRadius {
    static let small: CGFloat = 10
    static let medium: CGFloat = 16
    static let large: CGFloat = 22
    static let xlarge: CGFloat = 28
}

enum AppTypography {
    static let eyebrow = Font.caption.weight(.bold)
    static let sectionTitle = Font.headline.weight(.semibold)
    static let cardTitle = Font.title3.weight(.semibold)
    static let metadata = Font.caption.weight(.medium)
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }

    init(light: UInt, dark: UInt) {
        self.init(UIColor { traitCollection in
            let hex = traitCollection.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255,
                alpha: 1
            )
        })
    }
}
