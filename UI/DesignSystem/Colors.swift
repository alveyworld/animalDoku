import SwiftUI

/// Semantic color tokens for Animal Doku.
/// GDD: soft, minimal UI with pastel colors.
enum AppColors {
    // MARK: - Default (pastel)

    /// Main screen background — warm cream pastel.
    static let background = Color(red: 0.98, green: 0.97, blue: 0.95)

    /// Cards, sheets, and board surface.
    static let surface = Color(red: 1.0, green: 1.0, blue: 1.0)

    /// Primary text and icons.
    static let primary = Color(red: 0.30, green: 0.38, blue: 0.48)

    /// Interactive accents — toolbar highlights, selected states.
    static let accent = Color(red: 0.52, green: 0.72, blue: 0.62)

    /// Rule violations and error states.
    static let error = Color(red: 0.88, green: 0.42, blue: 0.42)

    /// Subtle dividers and grid lines.
    static let border = Color(red: 0.82, green: 0.84, blue: 0.86)

    /// Secondary labels and hints.
    static let secondary = Color(red: 0.55, green: 0.58, blue: 0.62)

    /// Pattern strokes for colorblind region overlays (P3.10).
    static let patternOverlay = Color.black

    // MARK: - Region palette

    /// Pastel region fills for the 8×8 board. Paired with borders/patterns for colorblind support (GDD accessibility).
    static let regionPalette: [Color] = [
        Color(red: 0.85, green: 0.92, blue: 0.98), // sky
        Color(red: 0.92, green: 0.88, blue: 0.98), // lavender
        Color(red: 0.88, green: 0.96, blue: 0.90), // mint
        Color(red: 0.98, green: 0.90, blue: 0.88), // peach
        Color(red: 0.98, green: 0.95, blue: 0.82), // butter
        Color(red: 0.90, green: 0.94, blue: 0.98), // periwinkle
        Color(red: 0.94, green: 0.90, blue: 0.96), // lilac
        Color(red: 0.88, green: 0.96, blue: 0.96), // aqua
    ]

    // MARK: - High contrast

    /// High-contrast variants for accessibility toggle (P5.3).
    /// GDD: increased border weight; text/icon contrast ratio ≥ 4.5:1.
    enum HighContrast {
        static let background = Color.white
        static let surface = Color(white: 0.95)
        static let primary = Color.black
        static let accent = Color(red: 0.0, green: 0.35, blue: 0.55)
        static let error = Color(red: 0.75, green: 0.0, blue: 0.0)
        static let border = Color.black
        static let secondary = Color(white: 0.25)

        /// Stronger region fills with higher saturation for contrast mode.
        static let regionPalette: [Color] = [
            Color(red: 0.70, green: 0.85, blue: 1.0),
            Color(red: 0.80, green: 0.70, blue: 1.0),
            Color(red: 0.65, green: 0.90, blue: 0.70),
            Color(red: 1.0, green: 0.75, blue: 0.70),
            Color(red: 1.0, green: 0.90, blue: 0.55),
            Color(red: 0.70, green: 0.80, blue: 1.0),
            Color(red: 0.85, green: 0.70, blue: 0.95),
            Color(red: 0.65, green: 0.90, blue: 0.90),
        ]

        /// Border stroke width for cells and regions in high contrast mode.
        static let borderWeight: CGFloat = 3.0
    }

    // MARK: - Helpers

    static func regionColor(at index: Int, highContrast: Bool = false) -> Color {
        let palette = highContrast ? HighContrast.regionPalette : regionPalette
        guard !palette.isEmpty else { return surface }
        return palette[index % palette.count]
    }

    static func resolvedBorder(highContrast: Bool = false) -> Color {
        highContrast ? HighContrast.border : border
    }

    static func borderWeight(highContrast: Bool = false) -> CGFloat {
        highContrast ? HighContrast.borderWeight : AppSpacing.borderWeight
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
