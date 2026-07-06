import XCTest
@testable import AnimalDoku

final class GameActionSaveGameTests: XCTestCase {
    func testPlaceUndoRestoresPreviousState() {
        let action = GameAction.place(at: Position(row: 0, col: 0), previous: .empty)
        var cell = Cell(row: 0, col: 0, regionId: 0, state: .animal)

        cell.state = action.previousState

        XCTAssertEqual(cell.state, .empty)
    }

    func testToggleBlockedUndoRestoresPreviousState() {
        let blockAction = GameAction.toggleBlocked(at: Position(row: 1, col: 1), previous: .empty)
        var blockedCell = Cell(row: 1, col: 1, regionId: 0, state: .blocked)

        blockedCell.state = blockAction.previousState
        XCTAssertEqual(blockedCell.state, .empty)

        let clearAction = GameAction.toggleBlocked(at: Position(row: 2, col: 2), previous: .blocked)
        var clearedCell = Cell(row: 2, col: 2, regionId: 0, state: .empty)

        clearedCell.state = clearAction.previousState
        XCTAssertEqual(clearedCell.state, .blocked)
    }

    func testHintIsDistinguishableFromPlace() {
        let position = Position(row: 3, col: 4)
        let hint = GameAction.hint(at: position, previous: .empty)
        let place = GameAction.place(at: position, previous: .empty)

        XCTAssertTrue(hint.isHint)
        XCTAssertFalse(place.isHint)
        XCTAssertNotEqual(hint, place)
    }

    func testSaveGameRoundTripEncoding() throws {
        let original = SaveGame(
            puzzleId: "puzzle-001",
            elapsedSeconds: 120,
            cells: [
                Cell(row: 0, col: 0, regionId: 0, state: .animal),
                Cell(row: 0, col: 1, regionId: 0, state: .blocked),
                Cell(row: 1, col: 0, regionId: 1, state: .empty),
            ],
            hintsUsed: 2,
            mistakes: 0,
            completed: false
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SaveGame.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    func testRemoveActionCarriesPreviousAnimalState() {
        let action = GameAction.remove(at: Position(row: 5, col: 5), previous: .animal)
        XCTAssertEqual(action.previousState, .animal)
        XCTAssertEqual(action.position, Position(row: 5, col: 5))
    }
}
