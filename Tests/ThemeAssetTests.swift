import XCTest
@testable import AnimalDoku

final class ThemeAssetTests: XCTestCase {
    func testMVPThemeIconNamesAreDefined() {
        XCTAssertEqual(ThemeAsset.iconName(for: "frogs"), "theme-frogs-icon")
        XCTAssertEqual(ThemeAsset.iconName(for: "dogs"), "theme-dogs-icon")
        XCTAssertEqual(ThemeAsset.iconName(for: "foxes"), "theme-foxes-icon")
        XCTAssertEqual(ThemeAsset.iconName(for: "bears"), "theme-bears-icon")
        XCTAssertEqual(ThemeAsset.iconName(for: "alligators"), "theme-alligators-icon")
    }

    func testUnknownThemeFallsBackToFrogsIcon() {
        XCTAssertEqual(ThemeAsset.iconName(for: "birds"), ThemeAsset.frogsIcon)
    }

    func testImageFallbackDoesNotCrashWhenAssetsAreEmpty() {
        for theme in ThemeCatalog.all {
            _ = ThemeAsset.image(for: theme)
        }
    }

    func testCartoonHeadRasterAssetsExist() {
        for theme in ThemeCatalog.all {
            XCTAssertTrue(
                ThemeAsset.hasRasterIcon(for: theme),
                "Missing raster icon for \(theme.id) (\(theme.icon))"
            )
        }
    }
}
