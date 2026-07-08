import XCTest
@testable import AnimalDoku

final class HintServiceTests: XCTestCase {
    private let service = HintService()

    func testTargetUsesSelectedEmptySolutionCell() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let board = rowMajorEmptyBoard(for: puzzle)
        let selected = Position(row: 3, col: 2)

        let target = service.targetPosition(
            board: board,
            solution: puzzle.solution,
            size: puzzle.size,
            selected: selected
        )

        XCTAssertEqual(target, selected)
    }

    func testTargetRejectsBlockedSelection() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        var board = rowMajorEmptyBoard(for: puzzle)
        let selected = Position(row: 0, col: 1)
        board[index(for: selected, size: puzzle.size)].state = .blocked

        let target = service.targetPosition(
            board: board,
            solution: puzzle.solution,
            size: puzzle.size,
            selected: selected
        )

        XCTAssertNil(target)
    }

    func testTargetPicksFirstRowMajorSolutionCellWithoutSelection() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let board = rowMajorEmptyBoard(for: puzzle)

        let target = service.targetPosition(
            board: board,
            solution: puzzle.solution,
            size: puzzle.size,
            selected: nil
        )

        XCTAssertEqual(target, Position(row: 0, col: 1))
    }

    func testCanHintRequiresRemainingQuota() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let board = rowMajorEmptyBoard(for: puzzle)

        XCTAssertTrue(
            service.canHint(
                hintsUsed: 0,
                completed: false,
                board: board,
                solution: puzzle.solution,
                size: puzzle.size,
                selected: nil
            )
        )

        XCTAssertFalse(
            service.canHint(
                hintsUsed: 3,
                completed: false,
                board: board,
                solution: puzzle.solution,
                size: puzzle.size,
                selected: nil
            )
        )
    }

    private func rowMajorEmptyBoard(for puzzle: Puzzle) -> [Cell] {
        var regionLookup: [Position: Int] = [:]
        for region in puzzle.regions {
            for position in region.cells {
                regionLookup[position] = region.id
            }
        }

        var cells: [Cell] = []
        for row in 0..<puzzle.size {
            for col in 0..<puzzle.size {
                cells.append(
                    Cell(
                        row: row,
                        col: col,
                        regionId: regionLookup[Position(row: row, col: col)] ?? 0,
                        state: .empty
                    )
                )
            }
        }
        return cells
    }

    private func index(for position: Position, size: Int) -> Int {
        position.row * size + position.col
    }
}
