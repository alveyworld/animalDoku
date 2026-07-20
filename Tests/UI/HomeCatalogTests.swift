import XCTest
@testable import AnimalDoku

final class HomeCatalogTests: XCTestCase {
    private func puzzle(id: String, difficulty: Difficulty) -> Puzzle {
        Puzzle(
            id: id,
            size: 4,
            regions: [],
            solution: [],
            difficulty: difficulty,
            initialPlacements: []
        )
    }

    func testFilterNilReturnsAllInOrder() {
        let puzzles = [
            puzzle(id: "a", difficulty: .hard),
            puzzle(id: "b", difficulty: .easy),
            puzzle(id: "c", difficulty: .medium),
        ]

        XCTAssertEqual(
            HomeCatalog.filtered(puzzles, difficulty: nil).map(\.id),
            ["a", "b", "c"]
        )
    }

    func testFilterByDifficulty() {
        let puzzles = [
            puzzle(id: "easy-1", difficulty: .easy),
            puzzle(id: "hard-1", difficulty: .hard),
            puzzle(id: "easy-2", difficulty: .easy),
            puzzle(id: "expert-1", difficulty: .expert),
        ]

        XCTAssertEqual(
            HomeCatalog.filtered(puzzles, difficulty: .easy).map(\.id),
            ["easy-1", "easy-2"]
        )
        XCTAssertEqual(
            HomeCatalog.filtered(puzzles, difficulty: .hard).map(\.id),
            ["hard-1"]
        )
        XCTAssertTrue(HomeCatalog.filtered(puzzles, difficulty: .medium).isEmpty)
    }

    func testDifficultyDisplayNamesAreNonEmpty() {
        for difficulty in Difficulty.allCases {
            XCTAssertFalse(difficulty.displayName.isEmpty)
        }
    }

    func testLoadAvailablePuzzlesSkipsInvalidFiles() throws {
        let loader = PuzzleLoader()
        let available = loader.loadAvailablePuzzles()
        let names = Set(available.map(\.id))

        XCTAssertTrue(names.contains("puzzle-001"))
        XCTAssertTrue(names.contains("puzzle-valid-4x4"))
        XCTAssertEqual(available.count, loader.availablePuzzleNames().count)
    }

    func testPlayableCatalogExcludesNonStandardBoardSizes() {
        let puzzles = [
            puzzle(id: "mini", difficulty: .easy),
            Puzzle(
                id: "full",
                size: 8,
                regions: [],
                solution: [],
                difficulty: .medium,
                initialPlacements: []
            ),
        ]

        XCTAssertEqual(HomeCatalog.playable(puzzles).map(\.id), ["full"])
    }

    func testBundledCatalogHasTwoNewPuzzlesPerDifficulty() {
        let playable = HomeCatalog.playable(PuzzleLoader().loadAvailablePuzzles())
        let expectedNew: [Difficulty: Set<String>] = [
            .easy: ["puzzle-002", "puzzle-003"],
            .medium: ["puzzle-004", "puzzle-005"],
            .hard: ["puzzle-006", "puzzle-007"],
            .expert: ["puzzle-008", "puzzle-009"],
        ]

        for (difficulty, ids) in expectedNew {
            let found = Set(playable.filter { $0.difficulty == difficulty }.map(\.id))
            XCTAssertTrue(
                ids.isSubset(of: found),
                "Missing \(difficulty.rawValue) puzzles: \(ids.subtracting(found))"
            )
        }

        XCTAssertTrue(playable.contains(where: { $0.id == "puzzle-001" }))
        XCTAssertFalse(playable.contains(where: { $0.id == "puzzle-valid-4x4" }))
    }

    func testNewPuzzlesHaveVariableRegionSizes() throws {
        let ids = (2...9).map { String(format: "puzzle-%03d", $0) }
        let loader = PuzzleLoader()

        for id in ids {
            let puzzle = try loader.load(named: id)
            let sizes = Set(puzzle.regions.map(\.cells.count))
            XCTAssertGreaterThanOrEqual(
                sizes.count,
                2,
                "\(id) should have variable region sizes, got \(sizes.sorted())"
            )
        }
    }

    func testResumeBadgeReflectsSaveStore() {
        let puzzle = TestPuzzleFactory.miniPuzzle()
        let store = InMemorySaveGameStore()
        XCTAssertNil(store.load(puzzleId: puzzle.id))

        let session = GameSession(puzzle: puzzle)
        session.placeOrRemove(at: Position(row: 0, col: 0))
        store.save(session.makeSaveGame())

        XCTAssertNotNil(store.load(puzzleId: puzzle.id))
    }
}
