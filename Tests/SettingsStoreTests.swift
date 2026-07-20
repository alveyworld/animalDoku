import XCTest
@testable import AnimalDoku

final class SettingsStoreTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "SettingsStoreTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testFreshInstallUsesDefaults() {
        let store = SettingsStore(defaults: defaults)

        XCTAssertEqual(store.selectedThemeId, "frogs")
        XCTAssertTrue(store.soundEnabled)
        XCTAssertFalse(store.highContrastEnabled)
        XCTAssertFalse(store.tutorialCompleted)
        XCTAssertTrue(store.hapticsEnabled)
        XCTAssertEqual(store.selectedTheme.id, "frogs")
    }

    func testSelectedThemePersistsAcrossInstances() {
        let store = SettingsStore(defaults: defaults)
        store.selectedThemeId = "foxes"

        let reloaded = SettingsStore(defaults: defaults)
        XCTAssertEqual(reloaded.selectedThemeId, "foxes")
    }

    func testSoundEnabledPersistsAcrossRelaunch() {
        let store = SettingsStore(defaults: defaults)
        store.soundEnabled = false

        let reloaded = SettingsStore(defaults: defaults)
        XCTAssertFalse(reloaded.soundEnabled)
    }

    func testHighContrastEnabledPersistsAcrossRelaunch() {
        let store = SettingsStore(defaults: defaults)
        store.highContrastEnabled = true

        let reloaded = SettingsStore(defaults: defaults)
        XCTAssertTrue(reloaded.highContrastEnabled)
    }

    func testTutorialCompletedPersistsAcrossRelaunch() {
        let store = SettingsStore(defaults: defaults)
        XCTAssertFalse(store.tutorialCompleted)

        store.completeTutorial()
        XCTAssertTrue(store.tutorialCompleted)

        let reloaded = SettingsStore(defaults: defaults)
        XCTAssertTrue(reloaded.tutorialCompleted)
    }

    func testHapticsEnabledPersistsAcrossRelaunch() {
        let store = SettingsStore(defaults: defaults)
        store.hapticsEnabled = false

        let reloaded = SettingsStore(defaults: defaults)
        XCTAssertFalse(reloaded.hapticsEnabled)
    }

    func testUnknownStoredThemeFallsBackToFrogs() {
        defaults.set("birds", forKey: SettingsStore.Keys.selectedThemeId)

        let store = SettingsStore(defaults: defaults)
        XCTAssertEqual(store.selectedThemeId, "frogs")
    }
}
