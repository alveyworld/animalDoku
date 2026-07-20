import XCTest
@testable import AnimalDoku

final class WinScreenTests: XCTestCase {
    func testTitleMatchesGDD() {
        XCTAssertEqual(WinScreenAccessibility.title, "Puzzle Complete!")
    }

    func testPlayAgainAccessibilityLabel() {
        XCTAssertEqual(WinScreenAccessibility.playAgainLabel, "Play again")
    }

    func testElapsedTimeDisplayForWinScreen() {
        XCTAssertEqual(ElapsedTimeFormatting.display(seconds: 125), "02:05")
        XCTAssertEqual(
            ElapsedTimeFormatting.accessibilityLabel(seconds: 125),
            "2 minutes 5 seconds"
        )
    }

    func testWinOverlayUsesSharedMotionPolicy() {
        XCTAssertNil(Motion.winOverlayAnimation(reduceMotion: true))
        XCTAssertNotNil(Motion.winOverlayAnimation(reduceMotion: false))
        XCTAssertLessThanOrEqual(Motion.winDuration, 0.3)
    }
}
