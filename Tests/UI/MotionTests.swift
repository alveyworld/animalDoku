import XCTest
@testable import AnimalDoku

final class MotionTests: XCTestCase {
    func testPlaceDurationIsWithinGDDTarget() {
        XCTAssertGreaterThanOrEqual(Motion.placeDuration, 0.15)
        XCTAssertLessThanOrEqual(Motion.placeDuration, 0.25)
    }

    func testRemoveDurationIsWithinGDDTarget() {
        XCTAssertGreaterThanOrEqual(Motion.removeDuration, 0.15)
        XCTAssertLessThanOrEqual(Motion.removeDuration, 0.25)
    }

    func testCellStateAnimationIsNilWhenReduceMotionEnabled() {
        XCTAssertNil(Motion.cellStateAnimation(reduceMotion: true))
    }

    func testCellStateAnimationIsActiveWhenReduceMotionDisabled() {
        XCTAssertNotNil(Motion.cellStateAnimation(reduceMotion: false))
    }

    func testRespectingReduceMotionReturnsNilWhenEnabled() {
        XCTAssertNil(Motion.respectingReduceMotion(true, curve: Motion.placeCurve))
    }

    func testRespectingReduceMotionReturnsCurveWhenDisabled() {
        XCTAssertNotNil(Motion.respectingReduceMotion(false, curve: Motion.placeCurve))
    }

    func testWinDurationIsWithinGDDTarget() {
        XCTAssertGreaterThan(Motion.winDuration, 0)
        XCTAssertLessThanOrEqual(Motion.winDuration, 0.3)
    }

    func testWinOverlayAnimationIsNilWhenReduceMotionEnabled() {
        XCTAssertNil(Motion.winOverlayAnimation(reduceMotion: true))
    }

    func testWinOverlayAnimationIsActiveWhenReduceMotionDisabled() {
        XCTAssertNotNil(Motion.winOverlayAnimation(reduceMotion: false))
    }

    func testWinEntranceScaleIsSubtle() {
        XCTAssertGreaterThan(Motion.winEntranceScale, 0.9)
        XCTAssertLessThan(Motion.winEntranceScale, 1.0)
    }
}
