import XCTest
@testable import AnimalDoku

final class ValidatorUniquenessTests: XCTestCase {
    private let validator = Validator()

    func testRowViolationListsBothAnimals() {
        let cells = [
            Cell(row: 0, col: 0, regionId: 0, state: .animal),
            Cell(row: 0, col: 2, regionId: 1, state: .animal),
        ]

        let violations = validator.uniquenessViolations(cells: cells, size: 4)

        XCTAssertEqual(violations.count, 1)
        XCTAssertEqual(violations[0].rule, .row)
        XCTAssertEqual(
            violations[0].positions,
            [Position(row: 0, col: 0), Position(row: 0, col: 2)]
        )
    }

    func testColumnViolationListsBothAnimals() {
        let cells = [
            Cell(row: 0, col: 1, regionId: 0, state: .animal),
            Cell(row: 2, col: 1, regionId: 1, state: .animal),
        ]

        let violations = validator.uniquenessViolations(cells: cells, size: 4)

        XCTAssertEqual(violations.count, 1)
        XCTAssertEqual(violations[0].rule, .column)
        XCTAssertEqual(
            violations[0].positions,
            [Position(row: 0, col: 1), Position(row: 2, col: 1)]
        )
    }

    func testRegionViolationListsBothAnimals() {
        let cells = [
            Cell(row: 0, col: 0, regionId: 2, state: .animal),
            Cell(row: 3, col: 3, regionId: 2, state: .animal),
        ]

        let violations = validator.uniquenessViolations(cells: cells, size: 4)

        XCTAssertEqual(violations.count, 1)
        XCTAssertEqual(violations[0].rule, .region)
        XCTAssertEqual(
            violations[0].positions,
            [Position(row: 0, col: 0), Position(row: 3, col: 3)]
        )
    }

    func testValidBoardHasNoUniquenessViolations() {
        let cells = [
            Cell(row: 0, col: 1, regionId: 0, state: .animal),
            Cell(row: 1, col: 3, regionId: 1, state: .animal),
            Cell(row: 2, col: 0, regionId: 2, state: .animal),
            Cell(row: 3, col: 2, regionId: 3, state: .animal),
        ]

        XCTAssertTrue(validator.uniquenessViolations(cells: cells, size: 4).isEmpty)
    }

    func testEmptyBoardHasNoViolations() {
        XCTAssertTrue(validator.uniquenessViolations(cells: [], size: 4).isEmpty)
    }

    func testTripleInRowProducesSingleViolationWithThreePositions() {
        let cells = [
            Cell(row: 1, col: 0, regionId: 0, state: .animal),
            Cell(row: 1, col: 2, regionId: 1, state: .animal),
            Cell(row: 1, col: 3, regionId: 2, state: .animal),
        ]

        let violations = validator.uniquenessViolations(cells: cells, size: 4)
        let rowViolations = violations.filter { $0.rule == .row }

        XCTAssertEqual(rowViolations.count, 1)
        XCTAssertEqual(rowViolations[0].positions.count, 3)
    }

    func testMultipleSimultaneousUniquenessViolations() {
        let cells = [
            Cell(row: 0, col: 0, regionId: 0, state: .animal),
            Cell(row: 0, col: 1, regionId: 0, state: .animal),
        ]

        let violations = validator.uniquenessViolations(cells: cells, size: 2)
        let rules = Set(violations.map(\.rule))

        XCTAssertTrue(rules.contains(.row))
        XCTAssertTrue(rules.contains(.region))
        XCTAssertGreaterThanOrEqual(violations.count, 2)
    }
}
