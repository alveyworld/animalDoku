import XCTest
@testable import AnimalDoku

final class SettingsViewTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "SettingsViewTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testCopyKeysAreNonEmpty() {
        XCTAssertFalse(SettingsViewAccessibility.title.isEmpty)
        XCTAssertFalse(SettingsViewAccessibility.soundLabel.isEmpty)
        XCTAssertFalse(SettingsViewAccessibility.hapticsLabel.isEmpty)
        XCTAssertFalse(SettingsViewAccessibility.highContrastLabel.isEmpty)
        XCTAssertFalse(SettingsViewAccessibility.themeSection.isEmpty)
        XCTAssertFalse(SettingsViewAccessibility.openSettingsLabel.isEmpty)
        XCTAssertFalse(SettingsViewAccessibility.openSettingsHint.isEmpty)
        XCTAssertFalse(SettingsViewAccessibility.showTutorialHint.isEmpty)
        XCTAssertFalse(SettingsViewAccessibility.doneLabel.isEmpty)
    }

    func testSoundToggleBindingUpdatesStore() {
        let store = SettingsStore(defaults: defaults)
        XCTAssertTrue(store.soundEnabled)

        store.soundEnabled = false
        XCTAssertFalse(store.soundEnabled)
        XCTAssertFalse(SettingsStore(defaults: defaults).soundEnabled)
    }

    func testHighContrastToggleBindingUpdatesStore() {
        let store = SettingsStore(defaults: defaults)
        XCTAssertFalse(store.highContrastEnabled)

        store.highContrastEnabled = true
        XCTAssertTrue(store.highContrastEnabled)
        XCTAssertTrue(SettingsStore(defaults: defaults).highContrastEnabled)
    }

    func testThemeChangeFromSettingsDoesNotMutateGameSession() {
        let session = GameSession(puzzle: TestPuzzleFactory.miniPuzzle())
        session.placeOrRemove(at: Position(row: 0, col: 0))

        let cellsBefore = session.cells
        let undoBefore = session.undoStack.count

        let store = SettingsStore(defaults: defaults)
        store.selectedThemeId = "dogs"
        store.soundEnabled = false
        store.highContrastEnabled = true

        XCTAssertEqual(session.cells, cellsBefore)
        XCTAssertEqual(session.undoStack.count, undoBefore)
        XCTAssertEqual(store.selectedThemeId, "dogs")
        XCTAssertFalse(store.soundEnabled)
        XCTAssertTrue(store.highContrastEnabled)
    }
}
