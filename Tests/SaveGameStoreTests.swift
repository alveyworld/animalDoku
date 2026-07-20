import XCTest
@testable import AnimalDoku

final class SaveGameStoreTests: XCTestCase {
    private var directory: URL!
    private var store: SaveGameStore!

    override func setUp() {
        super.setUp()
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("SaveGameStoreTests-\(UUID().uuidString)", isDirectory: true)
        store = SaveGameStore(directory: directory)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: directory)
        directory = nil
        store = nil
        super.tearDown()
    }

    func testSaveLoadRoundTrip() {
        let game = makeSave(puzzleId: "puzzle-001", completed: false)
        store.save(game)

        let loaded = store.load(puzzleId: "puzzle-001")
        XCTAssertEqual(loaded, game)
    }

    func testClearRemovesSave() {
        store.save(makeSave(puzzleId: "puzzle-001", completed: false))
        store.clear(puzzleId: "puzzle-001")
        XCTAssertNil(store.load(puzzleId: "puzzle-001"))
    }

    func testClearAllRemovesEverySave() {
        store.save(makeSave(puzzleId: "puzzle-001", completed: false))
        store.save(makeSave(puzzleId: "puzzle-002", completed: false))
        store.clearAll()
        XCTAssertNil(store.load(puzzleId: "puzzle-001"))
        XCTAssertNil(store.load(puzzleId: "puzzle-002"))
    }

    func testCorruptPayloadIsDiscarded() throws {
        let url = directory.appendingPathComponent("puzzle-001.json")
        try Data("{not-json".utf8).write(to: url)

        XCTAssertNil(store.load(puzzleId: "puzzle-001"))
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    }

    func testUnknownSchemaVersionIsDiscarded() throws {
        let json = """
        {
          "schemaVersion": 99,
          "puzzleId": "puzzle-001",
          "elapsedSeconds": 10,
          "cells": [],
          "hintsUsed": 0,
          "mistakes": 0,
          "completed": false
        }
        """
        try Data(json.utf8).write(to: directory.appendingPathComponent("puzzle-001.json"))

        XCTAssertNil(store.load(puzzleId: "puzzle-001"))
    }

    func testMissingSaveReturnsNil() {
        XCTAssertNil(store.load(puzzleId: "does-not-exist"))
    }

    private func makeSave(puzzleId: String, completed: Bool) -> SaveGame {
        SaveGame(
            puzzleId: puzzleId,
            elapsedSeconds: 42,
            cells: [
                Cell(row: 0, col: 0, regionId: 0, state: .animal),
                Cell(row: 0, col: 1, regionId: 0, state: .blocked),
            ],
            hintsUsed: 1,
            mistakes: 0,
            completed: completed
        )
    }
}

final class GameSessionSaveRestoreTests: XCTestCase {
    func testRestoreReproducesBoardHintsAndTimer() throws {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let session = GameSession(puzzle: puzzle)
        session.placeOrRemove(at: Position(row: 0, col: 0))
        session.setElapsedSeconds(17)
        // Simulate a hint count without going through hint targeting.
        let save = SaveGame(
            puzzleId: puzzle.id,
            elapsedSeconds: 17,
            cells: session.cells.map { cell in
                var copy = cell
                if cell.row == 1 && cell.col == 1 { copy.state = .blocked }
                return copy
            },
            hintsUsed: 2,
            completed: false
        )

        let restored = GameSession(puzzle: puzzle)
        try restored.restore(from: save)

        XCTAssertEqual(restored.cells, save.cells)
        XCTAssertEqual(restored.elapsedSeconds, 17)
        XCTAssertEqual(restored.hintsUsed, 2)
        XCTAssertTrue(restored.undoStack.isEmpty)
        XCTAssertTrue(restored.redoStack.isEmpty)
    }

    func testRestoreRejectsPuzzleIdMismatch() {
        let session = GameSession(puzzle: TestPuzzleFactory.miniPuzzle())
        let save = SaveGame(
            puzzleId: "other-id",
            elapsedSeconds: 0,
            cells: session.cells,
            hintsUsed: 0,
            completed: false
        )

        XCTAssertThrowsError(try session.restore(from: save)) { error in
            XCTAssertEqual(error as? SaveGameRestoreError, .puzzleIdMismatch)
        }
    }

    func testViewModelPersistsAndRestoresAcrossInstances() {
        let store = InMemorySaveGameStore()
        let puzzle = TestPuzzleFactory.miniPuzzle()

        let first = GameViewModel(puzzle: puzzle, saveStore: store)
        first.handleCellDoubleTap(at: Position(row: 0, col: 0))
        first.pauseTimer()

        let saved = store.load(puzzleId: puzzle.id)
        XCTAssertNotNil(saved)
        XCTAssertEqual(saved?.cells.first { $0.row == 0 && $0.col == 0 }?.state, .animal)

        let second = GameViewModel(puzzle: puzzle, saveStore: store)
        XCTAssertEqual(second.cellState(at: Position(row: 0, col: 0)), .animal)
        XCTAssertEqual(second.elapsedSeconds, saved?.elapsedSeconds)
    }

    func testResetClearsPersistedSave() {
        let store = InMemorySaveGameStore()
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let viewModel = GameViewModel(puzzle: puzzle, saveStore: store)

        viewModel.handleCellDoubleTap(at: Position(row: 0, col: 0))
        XCTAssertNotNil(store.load(puzzleId: puzzle.id))

        viewModel.reset()
        XCTAssertNil(store.load(puzzleId: puzzle.id))
        XCTAssertTrue(viewModel.cells.allSatisfy { $0.state == .empty })
    }

    func testCompletedSaveRestoresWinState() {
        let store = InMemorySaveGameStore()
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let first = GameViewModel(puzzle: puzzle, saveStore: store)

        for position in puzzle.solution {
            first.handleCellDoubleTap(at: position)
        }
        XCTAssertTrue(first.showWinScreen)
        first.persistSave()

        let second = GameViewModel(puzzle: puzzle, saveStore: store)
        XCTAssertTrue(second.isCompleted)
        XCTAssertTrue(second.showWinScreen)
        XCTAssertEqual(second.elapsedSeconds, store.load(puzzleId: puzzle.id)?.elapsedSeconds)
    }
}

private extension GameViewModel {
    func cellState(at position: Position) -> CellState {
        cells.first { $0.row == position.row && $0.col == position.col }?.state ?? .empty
    }
}
