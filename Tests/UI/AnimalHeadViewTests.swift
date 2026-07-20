import XCTest
@testable import AnimalDoku

final class AnimalHeadViewTests: XCTestCase {
    func testLookAroundDurationIsWithinTarget() {
        XCTAssertGreaterThanOrEqual(Motion.lookAroundDuration, 0.8)
        XCTAssertLessThanOrEqual(Motion.lookAroundDuration, 1.5)
    }

    func testAllowsLookAroundHonorsReduceMotion() {
        XCTAssertFalse(Motion.allowsLookAround(reduceMotion: true))
        XCTAssertTrue(Motion.allowsLookAround(reduceMotion: false))
    }

    func testNeutralGazeIsZero() {
        XCTAssertEqual(AnimalGaze.neutral.offset, .zero)
        XCTAssertEqual(AnimalGaze.neutral.tiltDegrees, 0)
    }

    func testRasterHeadsAreAvailableForMVPThemes() {
        for theme in ThemeCatalog.all {
            XCTAssertTrue(
                ThemeAsset.hasRasterIcon(for: theme),
                "Missing cartoon head asset for \(theme.id)"
            )
        }
    }
}
