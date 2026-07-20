import XCTest
@testable import AnimalDoku

final class RecordingSoundService: SoundPlaying {
    private(set) var played: [GameSound] = []
    var isEnabled: Bool = true

    func play(_ sound: GameSound) {
        guard isEnabled else { return }
        played.append(sound)
    }

    func reset() {
        played.removeAll()
    }
}

final class SoundServiceTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "SoundServiceTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testPlayIsNoOpWhenSoundDisabled() {
        let settings = SettingsStore(defaults: defaults)
        settings.soundEnabled = false
        let recorder = RecordingSoundService()
        recorder.isEnabled = settings.soundEnabled

        recorder.play(.place)
        recorder.play(.remove)
        recorder.play(.win)

        XCTAssertTrue(recorder.played.isEmpty)
    }

    func testPlayRecordsWhenSoundEnabled() {
        let recorder = RecordingSoundService()
        recorder.isEnabled = true

        recorder.play(.place)
        recorder.play(.win)

        XCTAssertEqual(recorder.played, [.place, .win])
    }

    func testMissingAssetsDoNotCrash() {
        let settings = SettingsStore(defaults: defaults)
        let service = SoundService(settings: settings, bundle: Bundle(for: SoundServiceTests.self))

        XCTAssertNoThrow(service.play(.place))
        XCTAssertNoThrow(service.play(.remove))
        XCTAssertNoThrow(service.play(.win))
    }

    func testGameSoundResourceNames() {
        XCTAssertEqual(GameSound.place.resourceName, "place")
        XCTAssertEqual(GameSound.remove.resourceName, "remove")
        XCTAssertEqual(GameSound.win.resourceName, "win")
    }
}
