import SwiftUI

/// Home screen: browse and filter bundled puzzles, then open a game.
struct HomeView: View {
    @Environment(SaveGameStore.self) private var saveStore

    let puzzles: [Puzzle]
    @State private var difficultyFilter: Difficulty?
    /// Bumped on appear so Resume badges re-read saves after returning from Game.
    @State private var resumeRefreshToken = UUID()

    private var displayedPuzzles: [Puzzle] {
        HomeCatalog.filtered(puzzles, difficulty: difficultyFilter)
    }

    var body: some View {
        Group {
            if puzzles.isEmpty {
                emptyCatalog
            } else {
                puzzleList
            }
        }
        .navigationTitle(String(localized: "home.title", defaultValue: "AnimalDoku"))
        .accessibilityIdentifier("homeView")
        .onAppear {
            resumeRefreshToken = UUID()
        }
    }

    private var emptyCatalog: some View {
        ContentUnavailableView(
            String(localized: "home.empty.title", defaultValue: "No Puzzles"),
            systemImage: "square.grid.3x3",
            description: Text(
                String(
                    localized: "home.empty.message",
                    defaultValue: "No puzzles are available yet. Check back soon!"
                )
            )
        )
        .accessibilityIdentifier("homeEmptyCatalog")
    }

    private var puzzleList: some View {
        List {
            Section {
                Picker(
                    String(localized: "home.filter.label", defaultValue: "Difficulty"),
                    selection: $difficultyFilter
                ) {
                    Text(String(localized: "home.filter.all", defaultValue: "All"))
                        .tag(Difficulty?.none)
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.displayName)
                            .tag(Optional(difficulty))
                    }
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("homeDifficultyFilter")
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .listRowBackground(Color.clear)
            }

            if displayedPuzzles.isEmpty {
                Text(
                    String(
                        localized: "home.filter.empty",
                        defaultValue: "No puzzles match this difficulty."
                    )
                )
                .foregroundStyle(.secondary)
                .accessibilityIdentifier("homeFilterEmpty")
            } else {
                ForEach(displayedPuzzles) { puzzle in
                    NavigationLink(value: puzzle) {
                        PuzzleRow(
                            puzzle: puzzle,
                            hasSave: hasSave(for: puzzle.id)
                        )
                    }
                    .accessibilityIdentifier("homePuzzle_\(puzzle.id)")
                }
            }
        }
        .navigationDestination(for: Puzzle.self) { puzzle in
            GameView(puzzle: puzzle, saveStore: saveStore)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("gameView")
        }
    }

    private func hasSave(for puzzleId: String) -> Bool {
        _ = resumeRefreshToken
        return saveStore.load(puzzleId: puzzleId) != nil
    }
}

private struct PuzzleRow: View {
    let puzzle: Puzzle
    let hasSave: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(puzzleTitle)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            if hasSave {
                Text(String(localized: "home.resume.badge", defaultValue: "Resume"))
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.15))
                    .foregroundStyle(Color.accentColor)
                    .clipShape(Capsule())
                    .accessibilityIdentifier("homeResume_\(puzzle.id)")
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
    }

    private var puzzleTitle: String {
        puzzle.id
            .replacingOccurrences(of: "puzzle-", with: "Puzzle ")
            .replacingOccurrences(of: "-", with: " ")
    }

    private var subtitle: String {
        "\(puzzle.difficulty.displayName) · \(puzzle.size)×\(puzzle.size)"
    }

    private var accessibilityLabel: String {
        if hasSave {
            "\(puzzleTitle), \(subtitle), Resume"
        } else {
            "\(puzzleTitle), \(subtitle)"
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(
            puzzles: [
                Puzzle(
                    id: "puzzle-001",
                    size: 8,
                    regions: [],
                    solution: [],
                    difficulty: .easy,
                    initialPlacements: []
                ),
                Puzzle(
                    id: "puzzle-002",
                    size: 8,
                    regions: [],
                    solution: [],
                    difficulty: .hard,
                    initialPlacements: []
                ),
            ]
        )
        .environment(SaveGameStore())
    }
}
