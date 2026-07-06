import XCTest
@testable import AnimalDoku

final class ThemeAssetTests: XCTestCase {
    func testMVPThemeIconNamesAreDefined() {
        XCTAssertEqual(ThemeAsset.iconName(for: "frogs"), "theme-frogs-icon")
        XCTAssertEqual(ThemeAsset.iconName(for: "dogs"), "theme-dogs-icon")
        XCTAssertEqual(ThemeAsset.iconName(for: "foxes"), "theme-foxes-icon")
    }

    func testUnknownThemeFallsBackToFrogsIcon() {
        XCTAssertEqual(ThemeAsset.iconName(for: "birds"), ThemeAsset.frogsIcon)
    }

    func testImageFallbackDoesNotCrashWhenAssetsAreEmpty() {
        for themeID in ["frogs", "dogs", "foxes"] {
            _ = ThemeAsset.image(for: themeID)
        }
    }
}
