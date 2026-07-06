import XCTest
@testable import AnimalDoku

final class ValidatorAdjacencyTests: XCTestCase {
    private let validator = Validator()

    func testDiagonalAdjacencyReturnsViolation() {
        let cells = [
            Cell(row: 1, col: 1, regionId: 0, state: .animal),
            Cell(row: 2, col: 2, regionId: 1, state: .animal),
        ]

        let violations = validator.adjacencyViolations(cells: cells, size: 4)

        XCTAssertEqual(violations.count, 1)
        XCTAssertEqual(violations[0].rule, .adjacency)
        XCTAssertEqual(
            violations[0].positions,
            [Position(row: 1, col: 1), Position(row: 2, col: 2)]
        )
    }

    func testOrthogonalAdjacencyReturnsViolation() {
        let cells = [
            Cell(row: 2, col: 2, regionId: 0, state: .animal),
            Cell(row: 2, col: 3, regionId: 1, state: .animal),
        ]

        let violations = validator.adjacencyViolations(cells: cells, size: 4)

        XCTAssertEqual(violations.count, 1)
        XCTAssertEqual(violations[0].rule, .adjacency)
        XCTAssertEqual(
            violations[0].positions,
            [Position(row: 2, col: 2), Position(row: 2, col: 3)]
        )
    }

    func testSeparatedAnimalsHaveNoAdjacencyViolation() {
        let cells = [
            Cell(row: 0, col: 0, regionId: 0, state: .animal),
            Cell(row: 0, col: 2, regionId: 1, state: .animal),
            Cell(row: 2, col: 1, regionId: 2, state: .animal),
        ]

        XCTAssertTrue(validator.adjacencyViolations(cells: cells, size: 4).isEmpty)
    }

    func testCornerAdjacencyDoesNotAccessOutOfBounds() {
        let eastNeighbor = [
            Cell(row: 0, col: 0, regionId: 0, state: .animal),
            Cell(row: 0, col: 1, regionId: 1, state: .animal),
        ]
        let diagonalNeighbor = [
            Cell(row: 0, col: 0, regionId: 0, state: .animal),
            Cell(row: 1, col: 1, regionId: 1, state: .animal),
        ]

        XCTAssertEqual(validator.adjacencyViolations(cells: eastNeighbor, size: 4).count, 1)
        XCTAssertEqual(validator.adjacencyViolations(cells: diagonalNeighbor, size: 4).count, 1)
    }

    func testOppositeEdgesDoNotWrapAround() {
        let cells = [
            Cell(row: 3, col: 0, regionId: 0, state: .animal),
            Cell(row: 3, col: 3, regionId: 1, state: .animal),
        ]

        XCTAssertTrue(validator.adjacencyViolations(cells: cells, size: 4).isEmpty)
    }

    func testEmptyBoardHasNoAdjacencyViolations() {
        XCTAssertTrue(validator.adjacencyViolations(cells: [], size: 4).isEmpty)
    }
}
