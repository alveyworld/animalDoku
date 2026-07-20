import XCTest
import UIKit
@testable import AnimalDoku

final class RecordingHapticService: HapticPlaying {
    private(set) var played: [GameHaptic] = []

    func play(_ haptic: GameHaptic) {
        played.append(haptic)
    }

    func reset() {
        played.removeAll()
    }
}

final class HapticServiceTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "HapticServiceTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testPlayIsNoOpWhenHapticsDisabled() {
        let settings = SettingsStore(defaults: defaults)
        settings.hapticsEnabled = false
        var played: [GameHaptic] = []
        let service = HapticService(
            settings: settings,
            applicationState: { .active },
            playHandler: { played.append($0) }
        )

        service.play(.place)
        service.play(.win)

        XCTAssertTrue(played.isEmpty)
    }

    func testPlayIsNoOpWhenAppIsBackgrounded() {
        let settings = SettingsStore(defaults: defaults)
        settings.hapticsEnabled = true
        var played: [GameHaptic] = []
        let service = HapticService(
            settings: settings,
            applicationState: { .background },
            playHandler: { played.append($0) }
        )

        service.play(.place)
        service.play(.win)

        XCTAssertTrue(played.isEmpty)
    }

    func testPlayFiresWhenActiveAndEnabled() {
        let settings = SettingsStore(defaults: defaults)
        settings.hapticsEnabled = true
        var played: [GameHaptic] = []
        let service = HapticService(
            settings: settings,
            applicationState: { .active },
            playHandler: { played.append($0) }
        )

        service.play(.place)
        service.play(.win)

        XCTAssertEqual(played, [.place, .win])
    }

    func testViewModelPlaysPlaceHaptic() {
        let haptics = RecordingHapticService()
        let viewModel = GameViewModel(
            puzzle: TestPuzzleFactory.miniPuzzle(),
            hapticService: haptics
        )

        viewModel.handleCellDoubleTap(at: Position(row: 0, col: 0))

        XCTAssertEqual(haptics.played, [.place])
    }

    func testViewModelPlaysMarkHapticOnSingleTap() {
        let haptics = RecordingHapticService()
        let viewModel = GameViewModel(
            puzzle: TestPuzzleFactory.miniPuzzle(),
            hapticService: haptics
        )

        viewModel.handleCellSingleTap(at: Position(row: 0, col: 0))

        XCTAssertEqual(haptics.played, [.place])
    }

    func testViewModelDoesNotPlayHapticOnRemove() {
        let haptics = RecordingHapticService()
        let viewModel = GameViewModel(
            puzzle: TestPuzzleFactory.miniPuzzle(),
            hapticService: haptics
        )
        let position = Position(row: 0, col: 0)

        viewModel.handleCellDoubleTap(at: position)
        haptics.reset()
        viewModel.handleCellDoubleTap(at: position)

        XCTAssertTrue(haptics.played.isEmpty)
    }

    func testViewModelPlaysWinHapticOnce() {
        let haptics = RecordingHapticService()
        let viewModel = GameViewModel(
            puzzle: TestPuzzleFactory.miniPuzzle(),
            hapticService: haptics
        )

        for position in viewModel.puzzle.solution {
            viewModel.handleCellDoubleTap(at: position)
        }

        XCTAssertEqual(haptics.played.last, .win)
        XCTAssertEqual(haptics.played.filter { $0 == .win }.count, 1)
    }
}
