import XCTest
@testable import AnimalDoku

final class DesignSystemTests: XCTestCase {
    func testTouchTargetMinimumMeetsAccessibilityGuideline() {
        XCTAssertGreaterThanOrEqual(TouchTarget.minimum, 44)
    }

    func testHighContrastBorderIsStrongerThanDefault() {
        XCTAssertGreaterThan(
            AppColors.HighContrast.borderWeight,
            AppSpacing.borderWeight
        )
    }
}
