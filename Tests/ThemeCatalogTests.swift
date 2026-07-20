import XCTest
@testable import AnimalDoku

final class ThemeCatalogTests: XCTestCase {
    func testAllContainsExactlyThreeMVPThemes() {
        XCTAssertEqual(ThemeCatalog.all.count, 3)
        XCTAssertEqual(ThemeCatalog.all.map(\.id), ["frogs", "dogs", "foxes"])
    }

    func testDefaultThemeIsFrogs() {
        XCTAssertEqual(ThemeCatalog.defaultTheme.id, "frogs")
        XCTAssertEqual(ThemeCatalog.defaultThemeID, "frogs")
    }

    func testThemeLookupReturnsMatchingTheme() {
        let dogs = ThemeCatalog.theme(id: "dogs")

        XCTAssertEqual(dogs.id, "dogs")
        XCTAssertEqual(dogs.icon, "theme-dogs-icon")
        XCTAssertFalse(dogs.primaryColor.isEmpty)
        XCTAssertFalse(dogs.accentColor.isEmpty)
        XCTAssertEqual(dogs.displayName, "Dogs")
    }

    func testUnknownThemeFallsBackToFrogs() {
        XCTAssertEqual(ThemeCatalog.theme(id: "birds").id, "frogs")
        XCTAssertEqual(ThemeCatalog.theme(id: "").id, "frogs")
    }

    func testEachThemeHasDistinctColors() {
        let primaries = Set(ThemeCatalog.all.map(\.primaryColor))
        let accents = Set(ThemeCatalog.all.map(\.accentColor))

        XCTAssertEqual(primaries.count, 3)
        XCTAssertEqual(accents.count, 3)
    }

    func testEachThemeHasNonEmptyIconAndAnimal() {
        for theme in ThemeCatalog.all {
            XCTAssertFalse(theme.icon.isEmpty)
            XCTAssertFalse(theme.animal.isEmpty)
            XCTAssertFalse(theme.name.isEmpty)
        }
    }

    func testThemeAssetResolvesCatalogIcons() {
        XCTAssertEqual(ThemeAsset.iconName(for: "foxes"), ThemeCatalog.foxes.icon)
        XCTAssertEqual(ThemeAsset.allIconNames, ThemeCatalog.all.map(\.icon))
    }

    func testImageFallbackDoesNotCrashForAllCatalogThemes() {
        for theme in ThemeCatalog.all {
            _ = ThemeAsset.image(for: theme)
        }
    }
}
