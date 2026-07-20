import XCTest
@testable import AnimalDoku

final class DesignSystemTests: XCTestCase {
    func testTouchTargetMinimumMeetsAccessibilityGuideline() {
        XCTAssertGreaterThanOrEqual(TouchTarget.minimum, 44)
    }

    func testHighContrastBorderIsStrongerThanDefault() {
        XCTAssertGreaterThan(
            AppColors.HighContrast.borderWeight,
            AppSpacing.borderWeight
        )
        XCTAssertGreaterThan(
            AppColors.borderWeight(highContrast: true),
            AppColors.borderWeight(highContrast: false)
        )
    }

    func testHighContrastTokenResolversDifferFromDefault() {
        XCTAssertNotEqual(
            AppColors.resolvedPrimary(highContrast: true),
            AppColors.resolvedPrimary(highContrast: false)
        )
        XCTAssertNotEqual(
            AppColors.resolvedBorder(highContrast: true),
            AppColors.resolvedBorder(highContrast: false)
        )
        XCTAssertNotEqual(
            AppColors.resolvedBackground(highContrast: true),
            AppColors.resolvedBackground(highContrast: false)
        )
        XCTAssertNotEqual(
            AppColors.resolvedError(highContrast: true),
            AppColors.resolvedError(highContrast: false)
        )
    }

    func testHighContrastTextMeetsWCAGAAContrast() {
        let primaryOnBackground = AppColors.contrastRatio(
            foreground: .highContrastPrimary,
            background: .highContrastBackground
        )
        let secondaryOnBackground = AppColors.contrastRatio(
            foreground: .highContrastSecondary,
            background: .highContrastBackground
        )
        let accentOnBackground = AppColors.contrastRatio(
            foreground: .highContrastAccent,
            background: .highContrastBackground
        )
        let errorOnBackground = AppColors.contrastRatio(
            foreground: .highContrastError,
            background: .highContrastBackground
        )
        let primaryOnSurface = AppColors.contrastRatio(
            foreground: .highContrastPrimary,
            background: .highContrastSurface
        )

        XCTAssertGreaterThanOrEqual(primaryOnBackground, 4.5)
        XCTAssertGreaterThanOrEqual(secondaryOnBackground, 4.5)
        XCTAssertGreaterThanOrEqual(accentOnBackground, 4.5)
        XCTAssertGreaterThanOrEqual(errorOnBackground, 4.5)
        XCTAssertGreaterThanOrEqual(primaryOnSurface, 4.5)
    }

    func testDefaultTextMeetsWCAGAAContrast() {
        let primaryOnBackground = AppColors.contrastRatio(
            foreground: .defaultPrimary,
            background: .defaultBackground
        )
        let secondaryOnBackground = AppColors.contrastRatio(
            foreground: .defaultSecondary,
            background: .defaultBackground
        )
        let accentOnBackground = AppColors.contrastRatio(
            foreground: .defaultAccent,
            background: .defaultBackground
        )
        let errorOnBackground = AppColors.contrastRatio(
            foreground: .defaultError,
            background: .defaultBackground
        )
        let primaryOnSurface = AppColors.contrastRatio(
            foreground: .defaultPrimary,
            background: .defaultSurface
        )
        let accentOnSurface = AppColors.contrastRatio(
            foreground: .defaultAccent,
            background: .defaultSurface
        )

        XCTAssertGreaterThanOrEqual(primaryOnBackground, 4.5)
        XCTAssertGreaterThanOrEqual(secondaryOnBackground, 4.5)
        XCTAssertGreaterThanOrEqual(accentOnBackground, 4.5)
        XCTAssertGreaterThanOrEqual(errorOnBackground, 4.5)
        XCTAssertGreaterThanOrEqual(primaryOnSurface, 4.5)
        XCTAssertGreaterThanOrEqual(accentOnSurface, 4.5)
    }

    func testThemePrimaryColorsMeetWCAGAAOnBackground() {
        let background = AppColors.ContrastRGB.defaultBackground
        let themes: [(String, AppColors.ContrastRGB)] = [
            ("frogs", AppColors.ContrastRGB(red: 0x4A / 255, green: 0x7C / 255, blue: 0x59 / 255)),
            ("dogs", AppColors.ContrastRGB(red: 0x6B / 255, green: 0x4E / 255, blue: 0x3D / 255)),
            ("foxes", AppColors.ContrastRGB(red: 0x9B / 255, green: 0x45 / 255, blue: 0x18 / 255)),
        ]
        for (name, color) in themes {
            let ratio = AppColors.contrastRatio(foreground: color, background: background)
            XCTAssertGreaterThanOrEqual(ratio, 4.5, "\(name) primary contrast \(ratio)")
        }
    }

    func testAccessibleRegionPaletteHexesAndMapping() {
        let expected = [
            "#0072B2", "#E69F00", "#009E73", "#D55E00",
            "#56B4E9", "#CC79A7", "#F0E442", "#4D4D4D",
        ]
        XCTAssertEqual(AppColors.Accessible.regionHexes, expected)
        XCTAssertEqual(AppColors.regionPalette.count, 8)
        XCTAssertEqual(AppColors.HighContrast.regionPalette.count, 8)
        XCTAssertEqual(AppColors.Accessible.accentExtras.count, 4)

        for index in 0..<8 {
            XCTAssertEqual(
                AppColors.regionColor(at: index),
                AppColors.Accessible.color(hex: expected[index])
            )
            XCTAssertEqual(
                AppColors.regionColor(at: index, highContrast: true),
                AppColors.regionColor(at: index, highContrast: false)
            )
        }

        // Stable wrap for ids beyond the base eight.
        XCTAssertEqual(AppColors.regionColor(at: 8), AppColors.regionColor(at: 0))
    }

    func testHighContrastRegionPaletteMatchesAccessibleDefault() {
        XCTAssertEqual(AppColors.HighContrast.regionPalette.count, AppColors.regionPalette.count)
        XCTAssertEqual(
            AppColors.regionColor(at: 0, highContrast: true),
            AppColors.regionColor(at: 0, highContrast: false)
        )
    }
}
