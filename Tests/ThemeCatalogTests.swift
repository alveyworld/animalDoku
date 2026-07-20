import XCTest
@testable import AnimalDoku

final class ThemeCatalogTests: XCTestCase {
    func testAllContainsExpectedThemesInStableOrder() {
        XCTAssertEqual(ThemeCatalog.all.count, 15)
        XCTAssertEqual(
            ThemeCatalog.all.map(\.id),
            [
                "frogs", "dogs", "foxes",
                "bears", "tigers", "camels", "elephants", "rhinos", "monkeys",
                "parrots", "penguins", "gorillas", "zebras", "cows", "alligators",
            ]
        )
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

    func testExpandedThemeLookup() {
        let bears = ThemeCatalog.theme(id: "bears")
        XCTAssertEqual(bears.animal, "bear")
        XCTAssertEqual(bears.icon, "theme-bears-icon")
        XCTAssertEqual(bears.displayName, "Bears")
    }

    func testUnknownThemeFallsBackToFrogs() {
        XCTAssertEqual(ThemeCatalog.theme(id: "birds").id, "frogs")
        XCTAssertEqual(ThemeCatalog.theme(id: "").id, "frogs")
    }

    func testEachThemeHasDistinctColors() {
        let primaries = Set(ThemeCatalog.all.map(\.primaryColor))
        let accents = Set(ThemeCatalog.all.map(\.accentColor))

        XCTAssertEqual(primaries.count, ThemeCatalog.all.count)
        XCTAssertEqual(accents.count, ThemeCatalog.all.count)
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
