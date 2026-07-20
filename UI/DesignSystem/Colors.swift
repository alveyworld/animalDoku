import SwiftUI

/// Semantic color tokens for Animal Doku.
///
/// Region fills use the Phase 8 accessible palette (P8.1) — bright, solid colors
/// with no hatch/pattern overlays. Puzzle JSON hex is ignored at render time.
enum AppColors {
    // MARK: - Chrome

    /// Main screen background — warm cream.
    static let background = Color(red: 0.98, green: 0.97, blue: 0.95)

    /// Cards, sheets, and board surface.
    static let surface = Color(red: 1.0, green: 1.0, blue: 1.0)

    /// Primary text and board icons (dark for contrast on bright region fills).
    static let primary = Color(red: 0.20, green: 0.22, blue: 0.25)

    /// Interactive accents — toolbar highlights, selected states (≥4.5:1 on background).
    static let accent = Accessible.blue

    /// Rule violations and error states.
    static let error = Color(red: 0.72, green: 0.16, blue: 0.16)

    /// Cell / region outline (stronger after P8.1 so structure reads without hatch lines).
    static let border = Color(red: 0.45, green: 0.47, blue: 0.50)

    /// Secondary labels and hints.
    static let secondary = Color(red: 0.32, green: 0.34, blue: 0.38)

    /// Legacy pattern stroke token (P3.10). Board no longer draws patterns (P8.1).
    static let patternOverlay = Color.black

    // MARK: - Accessible palette (P8.1)

    /// Okabe–Ito–style accessible colors for regions and accents.
    enum Accessible {
        static let blueHex = "#0072B2"
        static let orangeHex = "#E69F00"
        static let greenHex = "#009E73"
        static let vermillionHex = "#D55E00"
        static let skyBlueHex = "#56B4E9"
        static let reddishPurpleHex = "#CC79A7"
        static let yellowHex = "#F0E442"
        static let darkGrayHex = "#4D4D4D"
        static let brightPinkHex = "#FF4DA6"
        static let tealHex = "#00BFC4"
        static let oliveHex = "#7CAE00"
        static let violetHex = "#8B5CF6"

        static let blue = color(hex: blueHex)
        static let orange = color(hex: orangeHex)
        static let green = color(hex: greenHex)
        static let vermillion = color(hex: vermillionHex)
        static let skyBlue = color(hex: skyBlueHex)
        static let reddishPurple = color(hex: reddishPurpleHex)
        static let yellow = color(hex: yellowHex)
        static let darkGray = color(hex: darkGrayHex)
        static let brightPink = color(hex: brightPinkHex)
        static let teal = color(hex: tealHex)
        static let olive = color(hex: oliveHex)
        static let violet = color(hex: violetHex)

        /// Stable mapping for region ids 0…7 on 8×8 boards.
        static let regionHexes: [String] = [
            blueHex,
            orangeHex,
            greenHex,
            vermillionHex,
            skyBlueHex,
            reddishPurpleHex,
            yellowHex,
            darkGrayHex,
        ]

        static let regionPalette: [Color] = regionHexes.map(color(hex:))

        /// Extra accents for larger boards / future chrome (not used by 8×8 regions).
        static let accentExtras: [Color] = [brightPink, teal, olive, violet]

        /// Parse `#RRGGBB` without calling `RegionColorMap` (avoids static init cycles).
        static func color(hex: String) -> Color {
            var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            if sanitized.hasPrefix("#") {
                sanitized.removeFirst()
            }
            guard sanitized.count == 6, let value = UInt64(sanitized, radix: 16) else {
                return .gray
            }
            return Color(
                red: Double((value >> 16) & 0xFF) / 255.0,
                green: Double((value >> 8) & 0xFF) / 255.0,
                blue: Double(value & 0xFF) / 255.0
            )
        }
    }

    // MARK: - Region palette

    /// Board region fills — accessible solid colors by `regionId` (P8.1).
    static let regionPalette: [Color] = Accessible.regionPalette

    // MARK: - High contrast

    /// High-contrast chrome (P5.3). Region fills stay on the accessible palette (P8.1).
    enum HighContrast {
        static let background = Color.white
        static let surface = Color(white: 0.95)
        static let primary = Color.black
        static let accent = Accessible.blue
        static let error = Color(red: 0.75, green: 0.0, blue: 0.0)
        static let border = Color.black
        static let secondary = Color(white: 0.25)

        /// Same accessible hues as default; distinction comes from chrome/borders.
        static let regionPalette: [Color] = Accessible.regionPalette

        /// Border stroke width for cells and regions in high contrast mode.
        static let borderWeight: CGFloat = 3.0
    }

    // MARK: - Helpers

    static func regionColor(at index: Int, highContrast: Bool = false) -> Color {
        let palette = highContrast ? HighContrast.regionPalette : regionPalette
        guard !palette.isEmpty else { return surface }
        return palette[index % palette.count]
    }

    static func resolvedBackground(highContrast: Bool = false) -> Color {
        highContrast ? HighContrast.background : background
    }

    static func resolvedSurface(highContrast: Bool = false) -> Color {
        highContrast ? HighContrast.surface : surface
    }

    static func resolvedPrimary(highContrast: Bool = false) -> Color {
        highContrast ? HighContrast.primary : primary
    }

    static func resolvedSecondary(highContrast: Bool = false) -> Color {
        highContrast ? HighContrast.secondary : secondary
    }

    static func resolvedAccent(highContrast: Bool = false) -> Color {
        highContrast ? HighContrast.accent : accent
    }

    static func resolvedError(highContrast: Bool = false) -> Color {
        highContrast ? HighContrast.error : error
    }

    static func resolvedBorder(highContrast: Bool = false) -> Color {
        highContrast ? HighContrast.border : border
    }

    static func resolvedPatternOverlay(highContrast: Bool = false) -> Color {
        highContrast ? Color.black : patternOverlay
    }

    static func borderWeight(highContrast: Bool = false) -> CGFloat {
        highContrast ? HighContrast.borderWeight : AppSpacing.borderWeight
    }

    /// Approximate WCAG contrast ratio for known token pairs (unit-test aid).
    static func contrastRatio(foreground: ContrastRGB, background: ContrastRGB) -> Double {
        let lighter = max(foreground.relativeLuminance, background.relativeLuminance)
        let darker = min(foreground.relativeLuminance, background.relativeLuminance)
        return (lighter + 0.05) / (darker + 0.05)
    }

    struct ContrastRGB {
        let red: Double
        let green: Double
        let blue: Double

        var relativeLuminance: Double {
            func channel(_ value: Double) -> Double {
                value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
            }
            return 0.2126 * channel(red) + 0.7152 * channel(green) + 0.0722 * channel(blue)
        }

        static let highContrastPrimary = ContrastRGB(red: 0, green: 0, blue: 0)
        static let highContrastBackground = ContrastRGB(red: 1, green: 1, blue: 1)
        static let highContrastSecondary = ContrastRGB(red: 0.25, green: 0.25, blue: 0.25)
        static let highContrastAccent = ContrastRGB(red: 0.0, green: 0.447, blue: 0.698) // #0072B2
        static let highContrastError = ContrastRGB(red: 0.75, green: 0.0, blue: 0.0)
        static let highContrastSurface = ContrastRGB(red: 0.95, green: 0.95, blue: 0.95)

        // Default chrome RGB — keep in sync with AppColors above.
        static let defaultBackground = ContrastRGB(red: 0.98, green: 0.97, blue: 0.95)
        static let defaultSurface = ContrastRGB(red: 1.0, green: 1.0, blue: 1.0)
        static let defaultPrimary = ContrastRGB(red: 0.20, green: 0.22, blue: 0.25)
        static let defaultSecondary = ContrastRGB(red: 0.32, green: 0.34, blue: 0.38)
        static let defaultAccent = ContrastRGB(red: 0.0, green: 0.447, blue: 0.698) // #0072B2
        static let defaultError = ContrastRGB(red: 0.72, green: 0.16, blue: 0.16)
    }
}

#if DEBUG
private struct ColorTokenSwatch: View {
    let name: String
    let color: Color

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall)
                .fill(color)
                .frame(width: 44, height: 44)
                .overlay(
                    RoundedRectangle(cornerRadius: AppSpacing.cornerRadiusSmall)
                        .stroke(AppColors.border, lineWidth: 1)
                )
            Text(name)
                .font(AppTypography.caption)
                .foregroundStyle(AppColors.primary)
        }
    }
}

#Preview("Design Tokens") {
    ScrollView {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Default")
                .font(AppTypography.title)
            ColorTokenSwatch(name: "background", color: AppColors.background)
            ColorTokenSwatch(name: "surface", color: AppColors.surface)
            ColorTokenSwatch(name: "primary", color: AppColors.primary)
            ColorTokenSwatch(name: "accent", color: AppColors.accent)
            ColorTokenSwatch(name: "error", color: AppColors.error)

            Text("Accessible regions")
                .font(AppTypography.title)
                .padding(.top, AppSpacing.sm)
            ForEach(Array(AppColors.Accessible.regionHexes.enumerated()), id: \.offset) { index, hex in
                ColorTokenSwatch(name: "region \(index) \(hex)", color: AppColors.regionColor(at: index))
            }

            Text("High Contrast")
                .font(AppTypography.title)
                .padding(.top, AppSpacing.sm)
            ColorTokenSwatch(name: "background", color: AppColors.HighContrast.background)
            ColorTokenSwatch(name: "primary", color: AppColors.HighContrast.primary)
            ColorTokenSwatch(name: "border", color: AppColors.HighContrast.border)
        }
        .padding(AppSpacing.md)
    }
    .background(AppColors.background)
}
#endif
