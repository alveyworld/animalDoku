import XCTest
@testable import AnimalDoku

/// Pattern style catalog tests (P3.10). Board rendering no longer applies overlays (P8.1).
final class RegionPatternTests: XCTestCase {
    func testForRegionMapsDeterministically() {
        XCTAssertEqual(RegionPatternStyle.forRegion(0), .dots)
        XCTAssertEqual(RegionPatternStyle.forRegion(1), .horizontalStripes)
        XCTAssertEqual(RegionPatternStyle.forRegion(3), .diagonalStripes)
        XCTAssertEqual(RegionPatternStyle.forRegion(7), .circles)
    }

    func testForRegionWrapsWithModulo() {
        XCTAssertEqual(RegionPatternStyle.forRegion(8), .dots)
        XCTAssertEqual(RegionPatternStyle.forRegion(11), .diagonalStripes)
    }

    func testMVPRegionIdsUseDistinctPatterns() {
        let styles = (0..<8).map { RegionPatternStyle.forRegion($0) }
        XCTAssertEqual(Set(styles).count, 8)
    }

    func testPatternCatalogHasAtLeastEightStyles() {
        XCTAssertGreaterThanOrEqual(RegionPatternStyle.allCases.count, 8)
    }

    func testBoardUsesSolidAccessibleFillsWithoutRequiringPatterns() {
        // Regression guard for P8.1 policy: region identity comes from the palette.
        XCTAssertEqual(AppColors.Accessible.regionHexes.count, 8)
        XCTAssertEqual(Set(AppColors.Accessible.regionHexes).count, 8)
    }
}
