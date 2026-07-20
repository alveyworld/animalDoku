import XCTest
@testable import AnimalDoku

final class ThemePickerTests: XCTestCase {
    func testAccessibilityLabelIncludesSelectedState() {
        let frogs = ThemeCatalog.frogs
        XCTAssertEqual(
            ThemePickerAccessibility.label(for: frogs, isSelected: true),
            "Frogs, selected"
        )
        XCTAssertEqual(
            ThemePickerAccessibility.label(for: frogs, isSelected: false),
            "Frogs"
        )
    }

    func testSelectingThemeUpdatesSettingsStore() {
        let suiteName = "ThemePickerTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = SettingsStore(defaults: defaults)
        store.selectedThemeId = "dogs"

        XCTAssertEqual(store.selectedThemeId, "dogs")
        XCTAssertEqual(SettingsStore(defaults: defaults).selectedThemeId, "dogs")
    }

    func testThemeSwitchDoesNotMutateGameSession() {
        let session = GameSession(puzzle: TestPuzzleFactory.miniPuzzle())
        session.placeOrRemove(at: Position(row: 0, col: 0))

        let cellsBefore = session.cells
        let undoCountBefore = session.undoStack.count
        let validationBefore = session.validationResult

        let suiteName = "ThemePickerTests.session.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let store = SettingsStore(defaults: defaults)
        store.selectedThemeId = "foxes"

        XCTAssertEqual(session.cells, cellsBefore)
        XCTAssertEqual(session.undoStack.count, undoCountBefore)
        XCTAssertEqual(session.validationResult, validationBefore)
        XCTAssertEqual(store.selectedThemeId, "foxes")
    }

    func testCatalogListsThreeThemesForPicker() {
        XCTAssertEqual(ThemeCatalog.all.count, 3)
        XCTAssertEqual(
            ThemeCatalog.all.map(\.displayName),
            ["Frogs", "Dogs", "Foxes"]
        )
    }
}
