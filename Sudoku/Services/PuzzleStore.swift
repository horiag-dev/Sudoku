import Foundation

/// Storage for pre-made puzzles
class PuzzleStore {

    static let shared = PuzzleStore()

    private init() {}

    // MARK: - Pre-made Puzzles

    /// Collection of easy puzzles
    let easyPuzzles: [Puzzle] = [
        // Puzzle 1
        Puzzle(
            difficulty: .easy,
            initialBoard: [
                5, 3, 0, 0, 7, 0, 0, 0, 0,
                6, 0, 0, 1, 9, 5, 0, 0, 0,
                0, 9, 8, 0, 0, 0, 0, 6, 0,
                8, 0, 0, 0, 6, 0, 0, 0, 3,
                4, 0, 0, 8, 0, 3, 0, 0, 1,
                7, 0, 0, 0, 2, 0, 0, 0, 6,
                0, 6, 0, 0, 0, 0, 2, 8, 0,
                0, 0, 0, 4, 1, 9, 0, 0, 5,
                0, 0, 0, 0, 8, 0, 0, 7, 9
            ],
            solution: [
                5, 3, 4, 6, 7, 8, 9, 1, 2,
                6, 7, 2, 1, 9, 5, 3, 4, 8,
                1, 9, 8, 3, 4, 2, 5, 6, 7,
                8, 5, 9, 7, 6, 1, 4, 2, 3,
                4, 2, 6, 8, 5, 3, 7, 9, 1,
                7, 1, 3, 9, 2, 4, 8, 5, 6,
                9, 6, 1, 5, 3, 7, 2, 8, 4,
                2, 8, 7, 4, 1, 9, 6, 3, 5,
                3, 4, 5, 2, 8, 6, 1, 7, 9
            ]
        ),
        // Puzzle 2
        Puzzle(
            difficulty: .easy,
            initialBoard: [
                0, 0, 4, 0, 5, 0, 0, 0, 0,
                9, 0, 0, 7, 3, 4, 6, 0, 0,
                0, 0, 3, 0, 2, 1, 0, 4, 9,
                0, 3, 5, 0, 9, 0, 4, 8, 0,
                0, 9, 0, 0, 0, 0, 0, 3, 0,
                0, 7, 6, 0, 1, 0, 9, 2, 0,
                3, 1, 0, 9, 7, 0, 2, 0, 0,
                0, 0, 9, 1, 8, 2, 0, 0, 3,
                0, 0, 0, 0, 6, 0, 1, 0, 0
            ],
            solution: [
                1, 6, 4, 8, 5, 9, 3, 7, 2,
                9, 2, 8, 7, 3, 4, 6, 1, 5,
                7, 5, 3, 6, 2, 1, 8, 4, 9,
                2, 3, 5, 4, 9, 7, 4, 8, 6,
                4, 9, 1, 2, 8, 6, 5, 3, 7,
                8, 7, 6, 5, 1, 3, 9, 2, 4,
                3, 1, 8, 9, 7, 5, 2, 6, 4,
                6, 4, 9, 1, 8, 2, 7, 5, 3,
                5, 8, 2, 3, 6, 4, 1, 9, 7
            ]
        ),
        // Puzzle 3
        Puzzle(
            difficulty: .easy,
            initialBoard: [
                2, 0, 0, 3, 0, 0, 0, 0, 0,
                8, 0, 4, 0, 6, 2, 0, 0, 3,
                0, 1, 3, 8, 0, 0, 2, 0, 0,
                0, 0, 0, 0, 2, 0, 3, 9, 0,
                5, 0, 7, 0, 0, 0, 6, 2, 1,
                0, 3, 2, 0, 0, 6, 0, 0, 0,
                0, 2, 0, 0, 0, 9, 1, 4, 0,
                6, 0, 1, 2, 5, 0, 8, 0, 9,
                0, 0, 0, 0, 0, 1, 0, 0, 2
            ],
            solution: [
                2, 6, 9, 3, 1, 4, 5, 8, 7,
                8, 7, 4, 5, 6, 2, 9, 1, 3,
                4, 1, 3, 8, 9, 7, 2, 6, 5,
                1, 8, 6, 4, 2, 5, 3, 9, 4,
                5, 4, 7, 9, 3, 8, 6, 2, 1,
                9, 3, 2, 1, 7, 6, 4, 5, 8,
                3, 2, 5, 6, 8, 9, 1, 4, 6,
                6, 4, 1, 2, 5, 3, 8, 7, 9,
                7, 9, 8, 4, 4, 1, 5, 3, 2
            ]
        )
    ]

    /// Collection of medium puzzles
    let mediumPuzzles: [Puzzle] = [
        Puzzle(
            difficulty: .medium,
            initialBoard: [
                0, 0, 0, 2, 6, 0, 7, 0, 1,
                6, 8, 0, 0, 7, 0, 0, 9, 0,
                1, 9, 0, 0, 0, 4, 5, 0, 0,
                8, 2, 0, 1, 0, 0, 0, 4, 0,
                0, 0, 4, 6, 0, 2, 9, 0, 0,
                0, 5, 0, 0, 0, 3, 0, 2, 8,
                0, 0, 9, 3, 0, 0, 0, 7, 4,
                0, 4, 0, 0, 5, 0, 0, 3, 6,
                7, 0, 3, 0, 1, 8, 0, 0, 0
            ],
            solution: [
                4, 3, 5, 2, 6, 9, 7, 8, 1,
                6, 8, 2, 5, 7, 1, 4, 9, 3,
                1, 9, 7, 8, 3, 4, 5, 6, 2,
                8, 2, 6, 1, 9, 5, 3, 4, 7,
                3, 7, 4, 6, 8, 2, 9, 1, 5,
                9, 5, 1, 7, 4, 3, 6, 2, 8,
                5, 1, 9, 3, 2, 6, 8, 7, 4,
                2, 4, 8, 9, 5, 7, 1, 3, 6,
                7, 6, 3, 4, 1, 8, 2, 5, 9
            ]
        ),
        Puzzle(
            difficulty: .medium,
            initialBoard: [
                0, 2, 0, 6, 0, 8, 0, 0, 0,
                5, 8, 0, 0, 0, 9, 7, 0, 0,
                0, 0, 0, 0, 4, 0, 0, 0, 0,
                3, 7, 0, 0, 0, 0, 5, 0, 0,
                6, 0, 0, 0, 0, 0, 0, 0, 4,
                0, 0, 8, 0, 0, 0, 0, 1, 3,
                0, 0, 0, 0, 2, 0, 0, 0, 0,
                0, 0, 9, 8, 0, 0, 0, 3, 6,
                0, 0, 0, 3, 0, 6, 0, 9, 0
            ],
            solution: [
                1, 2, 3, 6, 7, 8, 9, 4, 5,
                5, 8, 4, 2, 3, 9, 7, 6, 1,
                9, 6, 7, 1, 4, 5, 3, 2, 8,
                3, 7, 2, 4, 6, 1, 5, 8, 9,
                6, 9, 1, 5, 8, 3, 2, 7, 4,
                4, 5, 8, 7, 9, 2, 6, 1, 3,
                8, 3, 6, 9, 2, 4, 1, 5, 7,
                2, 1, 9, 8, 5, 7, 4, 3, 6,
                7, 4, 5, 3, 1, 6, 8, 9, 2
            ]
        )
    ]

    /// Collection of hard puzzles
    let hardPuzzles: [Puzzle] = [
        Puzzle(
            difficulty: .hard,
            initialBoard: [
                0, 0, 0, 0, 0, 0, 0, 0, 0,
                0, 0, 0, 0, 0, 3, 0, 8, 5,
                0, 0, 1, 0, 2, 0, 0, 0, 0,
                0, 0, 0, 5, 0, 7, 0, 0, 0,
                0, 0, 4, 0, 0, 0, 1, 0, 0,
                0, 9, 0, 0, 0, 0, 0, 0, 0,
                5, 0, 0, 0, 0, 0, 0, 7, 3,
                0, 0, 2, 0, 1, 0, 0, 0, 0,
                0, 0, 0, 0, 4, 0, 0, 0, 9
            ],
            solution: [
                9, 8, 7, 6, 5, 4, 3, 2, 1,
                2, 4, 6, 1, 7, 3, 9, 8, 5,
                3, 5, 1, 9, 2, 8, 7, 4, 6,
                1, 2, 8, 5, 3, 7, 6, 9, 4,
                6, 3, 4, 8, 9, 2, 1, 5, 7,
                7, 9, 5, 4, 6, 1, 8, 3, 2,
                5, 1, 9, 2, 8, 6, 4, 7, 3,
                4, 7, 2, 3, 1, 9, 5, 6, 8,
                8, 6, 3, 7, 4, 5, 2, 1, 9
            ]
        ),
        Puzzle(
            difficulty: .hard,
            initialBoard: [
                0, 0, 5, 3, 0, 0, 0, 0, 0,
                8, 0, 0, 0, 0, 0, 0, 2, 0,
                0, 7, 0, 0, 1, 0, 5, 0, 0,
                4, 0, 0, 0, 0, 5, 3, 0, 0,
                0, 1, 0, 0, 7, 0, 0, 0, 6,
                0, 0, 3, 2, 0, 0, 0, 8, 0,
                0, 6, 0, 5, 0, 0, 0, 0, 9,
                0, 0, 4, 0, 0, 0, 0, 3, 0,
                0, 0, 0, 0, 0, 9, 7, 0, 0
            ],
            solution: [
                1, 4, 5, 3, 2, 7, 6, 9, 8,
                8, 3, 9, 6, 5, 4, 1, 2, 7,
                6, 7, 2, 9, 1, 8, 5, 4, 3,
                4, 9, 6, 1, 8, 5, 3, 7, 2,
                2, 1, 8, 4, 7, 3, 9, 5, 6,
                7, 5, 3, 2, 9, 6, 4, 8, 1,
                3, 6, 7, 5, 4, 2, 8, 1, 9,
                9, 8, 4, 7, 6, 1, 2, 3, 5,
                5, 2, 1, 8, 3, 9, 7, 6, 4
            ]
        )
    ]

    // MARK: - Access Methods

    /// Get all puzzles for a difficulty level
    func puzzles(for difficulty: Difficulty) -> [Puzzle] {
        switch difficulty {
        case .easy: return easyPuzzles
        case .medium: return mediumPuzzles
        case .hard: return hardPuzzles
        }
    }

    /// Get a random puzzle for a difficulty level
    func randomPuzzle(for difficulty: Difficulty) -> Puzzle {
        let available = puzzles(for: difficulty)
        if available.isEmpty {
            // Generate one if none available
            return PuzzleGenerator.generate(difficulty: difficulty)
        }
        return available.randomElement()!
    }

    /// Get a random puzzle, optionally generate a new one
    func getPuzzle(difficulty: Difficulty, generateNew: Bool = false) -> Puzzle {
        if generateNew {
            return PuzzleGenerator.generate(difficulty: difficulty)
        }
        return randomPuzzle(for: difficulty)
    }
}
