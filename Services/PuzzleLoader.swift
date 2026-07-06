import Foundation

/// Errors thrown when loading or validating bundled puzzle JSON.
enum PuzzleLoaderError: Error, Equatable {
    case fileNotFound(String)
    case decodingFailed(String)
    case regionsDoNotPartition
    case nonContiguousRegionIds
    case solutionLengthMismatch(expected: Int, got: Int)
}

/// Loads and validates hand-authored puzzle JSON from the app bundle.
/// Schema: [Formal Rules §Puzzle JSON Schema](AnimalDoku_Formal_Rules_and_Data_Model.md#puzzle-json-schema).
struct PuzzleLoader {
    func load(named name: String, in bundle: Bundle = .main) throws -> Puzzle {
        let resourceName = name.hasSuffix(".json") ? String(name.dropLast(5)) : name

        guard let url = bundle.url(forResource: resourceName, withExtension: "json", subdirectory: "Puzzles")
            ?? bundle.url(forResource: resourceName, withExtension: "json") else {
            throw PuzzleLoaderError.fileNotFound(resourceName)
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw PuzzleLoaderError.decodingFailed(error.localizedDescription)
        }

        return try load(from: data)
    }

    func load(from data: Data) throws -> Puzzle {
        let puzzle: Puzzle
        do {
            puzzle = try JSONDecoder().decode(Puzzle.self, from: data)
        } catch {
            throw PuzzleLoaderError.decodingFailed(error.localizedDescription)
        }

        try Self.validate(puzzle)
        return puzzle
    }

    func availablePuzzleNames(in bundle: Bundle = .main) -> [String] {
        var urls = bundle.urls(forResourcesWithExtension: "json", subdirectory: "Puzzles") ?? []
        if urls.isEmpty {
            urls = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        }

        return urls
            .map { $0.deletingPathExtension().lastPathComponent }
            .sorted()
    }

    static func validate(_ puzzle: Puzzle) throws {
        guard puzzle.solution.count == puzzle.size else {
            throw PuzzleLoaderError.solutionLengthMismatch(
                expected: puzzle.size,
                got: puzzle.solution.count
            )
        }

        let expectedRegionIds = Set(0..<puzzle.size)
        let actualRegionIds = Set(puzzle.regions.map(\.id))
        guard actualRegionIds == expectedRegionIds else {
            throw PuzzleLoaderError.nonContiguousRegionIds
        }

        var seenCells = Set<String>()
        for region in puzzle.regions {
            for position in region.cells {
                guard (0..<puzzle.size).contains(position.row),
                      (0..<puzzle.size).contains(position.col) else {
                    throw PuzzleLoaderError.regionsDoNotPartition
                }

                let key = "\(position.row),\(position.col)"
                guard seenCells.insert(key).inserted else {
                    throw PuzzleLoaderError.regionsDoNotPartition
                }
            }
        }

        guard seenCells.count == puzzle.size * puzzle.size else {
            throw PuzzleLoaderError.regionsDoNotPartition
        }
    }
}
