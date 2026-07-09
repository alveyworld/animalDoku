import XCTest
@testable import AnimalDoku

final class AppLaunchConfigurationTests: XCTestCase {
    func testDefaultPuzzleName() {
        let configuration = AppLaunchConfiguration(arguments: [])

        XCTAssertEqual(configuration.puzzleName, "puzzle-001")
        XCTAssertFalse(configuration.reduceMotion)
    }

    func testLaunchArgumentOverridesPuzzleName() {
        let configuration = AppLaunchConfiguration(
            arguments: ["-uiTestPuzzle", "puzzle-valid-4x4"]
        )

        XCTAssertEqual(configuration.puzzleName, "puzzle-valid-4x4")
    }

    func testReduceMotionLaunchFlag() {
        let configuration = AppLaunchConfiguration(
            arguments: ["-uiTestReduceMotion", "1"]
        )

        XCTAssertTrue(configuration.reduceMotion)
    }

    func testPuzzleNameParserReturnsDefaultWhenFlagMissingValue() {
        XCTAssertEqual(
            AppLaunchConfiguration.puzzleName(from: ["-uiTestPuzzle"]),
            AppLaunchConfiguration.defaultPuzzleName
        )
    }
}

final class ContentViewLaunchTests: XCTestCase {
    func testContentViewLoadsDefaultBundledPuzzle() throws {
        let configuration = AppLaunchConfiguration(arguments: [])
        let puzzle = try PuzzleLoader().load(named: configuration.puzzleName)

        XCTAssertEqual(puzzle.id, "puzzle-001")
        XCTAssertEqual(puzzle.size, 8)
    }

    func testContentViewCanLoadUITestPuzzleOverride() throws {
        let configuration = AppLaunchConfiguration(
            arguments: ["-uiTestPuzzle", "puzzle-valid-4x4"]
        )
        let puzzle = try PuzzleLoader().load(named: configuration.puzzleName)

        XCTAssertEqual(puzzle.id, "puzzle-valid-4x4")
    }
}
