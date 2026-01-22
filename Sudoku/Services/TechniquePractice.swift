import Foundation

/// Practice puzzles designed to teach specific techniques
class TechniquePractice {
    static let shared = TechniquePractice()
    private init() {}

    /// A practice puzzle with metadata about what technique it teaches
    struct PracticePuzzle: Identifiable {
        let id = UUID()
        let technique: TechniqueType
        let title: String
        let description: String
        let puzzle: Puzzle
        let hintCell: Int  // Cell where the technique applies
        let expectedValue: Int?  // For placement techniques
    }

    // MARK: - Naked Single Examples

    let nakedSinglePuzzles: [PracticePuzzle] = [
        PracticePuzzle(
            technique: .nakedSingle,
            title: "Your First Naked Single",
            description: "Find the cell where only one number can go. Look at R5C5 - what numbers are already in its row, column, and box?",
            puzzle: Puzzle(
                difficulty: .easy,
                initialBoard: [
                    5, 3, 4, 6, 7, 8, 9, 1, 2,
                    6, 7, 2, 1, 9, 5, 3, 4, 8,
                    1, 9, 8, 3, 4, 2, 5, 6, 7,
                    8, 5, 9, 7, 6, 1, 4, 2, 3,
                    4, 2, 6, 8, 0, 3, 7, 9, 1,  // R5C5 = 5
                    7, 1, 3, 9, 2, 4, 8, 5, 6,
                    9, 6, 1, 5, 3, 7, 2, 8, 4,
                    2, 8, 7, 4, 1, 9, 6, 3, 5,
                    3, 4, 5, 2, 8, 6, 1, 7, 9
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
            hintCell: 40,  // R5C5
            expectedValue: 5
        ),
        PracticePuzzle(
            technique: .nakedSingle,
            title: "Corner Naked Single",
            description: "The corner cell R1C1 has most numbers eliminated. What's the only possibility?",
            puzzle: Puzzle(
                difficulty: .easy,
                initialBoard: [
                    0, 2, 3, 4, 5, 6, 7, 8, 9,  // R1C1 = 1
                    4, 5, 6, 7, 8, 9, 1, 2, 3,
                    7, 8, 9, 1, 2, 3, 4, 5, 6,
                    2, 3, 4, 5, 6, 7, 8, 9, 1,
                    5, 6, 7, 8, 9, 1, 2, 3, 4,
                    8, 9, 1, 2, 3, 4, 5, 6, 7,
                    3, 4, 5, 6, 7, 8, 9, 1, 2,
                    6, 7, 8, 9, 1, 2, 3, 4, 5,
                    9, 1, 2, 3, 4, 5, 6, 7, 8
                ],
                solution: [
                    1, 2, 3, 4, 5, 6, 7, 8, 9,
                    4, 5, 6, 7, 8, 9, 1, 2, 3,
                    7, 8, 9, 1, 2, 3, 4, 5, 6,
                    2, 3, 4, 5, 6, 7, 8, 9, 1,
                    5, 6, 7, 8, 9, 1, 2, 3, 4,
                    8, 9, 1, 2, 3, 4, 5, 6, 7,
                    3, 4, 5, 6, 7, 8, 9, 1, 2,
                    6, 7, 8, 9, 1, 2, 3, 4, 5,
                    9, 1, 2, 3, 4, 5, 6, 7, 8
                ]
            ),
            hintCell: 0,
            expectedValue: 1
        ),
        PracticePuzzle(
            technique: .nakedSingle,
            title: "Middle Row Single",
            description: "In row 5, find the cell that can only be one number.",
            puzzle: Puzzle(
                difficulty: .easy,
                initialBoard: [
                    1, 2, 3, 4, 5, 6, 7, 8, 9,
                    4, 5, 6, 7, 8, 9, 1, 2, 3,
                    7, 8, 9, 1, 2, 3, 4, 5, 6,
                    2, 1, 4, 3, 6, 5, 8, 9, 7,
                    3, 6, 5, 8, 9, 7, 2, 0, 4,  // R5C8 = 1
                    8, 9, 7, 2, 1, 4, 3, 6, 5,
                    5, 3, 1, 6, 4, 2, 9, 7, 8,
                    6, 4, 2, 9, 7, 8, 5, 3, 1,
                    9, 7, 8, 5, 3, 1, 6, 4, 2
                ],
                solution: [
                    1, 2, 3, 4, 5, 6, 7, 8, 9,
                    4, 5, 6, 7, 8, 9, 1, 2, 3,
                    7, 8, 9, 1, 2, 3, 4, 5, 6,
                    2, 1, 4, 3, 6, 5, 8, 9, 7,
                    3, 6, 5, 8, 9, 7, 2, 1, 4,
                    8, 9, 7, 2, 1, 4, 3, 6, 5,
                    5, 3, 1, 6, 4, 2, 9, 7, 8,
                    6, 4, 2, 9, 7, 8, 5, 3, 1,
                    9, 7, 8, 5, 3, 1, 6, 4, 2
                ]
            ),
            hintCell: 43,
            expectedValue: 1
        )
    ]

    // MARK: - Hidden Single Examples

    let hiddenSinglePuzzles: [PracticePuzzle] = [
        PracticePuzzle(
            technique: .hiddenSingle,
            title: "Hidden Single in a Row",
            description: "In Row 1, where can the number 9 go? Only one cell is possible!",
            puzzle: Puzzle(
                difficulty: .easy,
                initialBoard: [
                    0, 2, 3, 4, 5, 6, 7, 8, 0,  // 9 can only go in R1C1
                    4, 5, 6, 7, 8, 9, 1, 2, 3,
                    7, 8, 9, 1, 2, 3, 4, 5, 6,
                    2, 1, 4, 3, 6, 5, 8, 9, 7,
                    3, 6, 5, 8, 9, 7, 2, 1, 4,
                    8, 9, 7, 2, 1, 4, 3, 6, 5,
                    5, 3, 1, 6, 4, 2, 9, 7, 8,
                    6, 4, 2, 9, 7, 8, 5, 3, 1,
                    9, 7, 8, 5, 3, 1, 6, 4, 2
                ],
                solution: [
                    1, 2, 3, 4, 5, 6, 7, 8, 9,
                    4, 5, 6, 7, 8, 9, 1, 2, 3,
                    7, 8, 9, 1, 2, 3, 4, 5, 6,
                    2, 1, 4, 3, 6, 5, 8, 9, 7,
                    3, 6, 5, 8, 9, 7, 2, 1, 4,
                    8, 9, 7, 2, 1, 4, 3, 6, 5,
                    5, 3, 1, 6, 4, 2, 9, 7, 8,
                    6, 4, 2, 9, 7, 8, 5, 3, 1,
                    9, 7, 8, 5, 3, 1, 6, 4, 2
                ]
            ),
            hintCell: 8,
            expectedValue: 9
        ),
        PracticePuzzle(
            technique: .hiddenSingle,
            title: "Hidden Single in a Box",
            description: "Look at Box 5 (the center box). Where must the number 5 go?",
            puzzle: Puzzle(
                difficulty: .easy,
                initialBoard: [
                    5, 3, 4, 6, 7, 8, 9, 1, 2,
                    6, 7, 2, 1, 9, 0, 3, 4, 8,  // 5 hidden in box 5
                    1, 9, 8, 3, 4, 2, 0, 6, 7,
                    8, 0, 9, 7, 6, 1, 4, 2, 3,
                    4, 2, 6, 8, 0, 3, 7, 9, 1,  // R5C5 must be 5 for box
                    7, 1, 3, 9, 2, 4, 8, 5, 6,
                    9, 6, 1, 0, 3, 7, 2, 8, 4,
                    2, 8, 7, 4, 1, 9, 6, 3, 5,
                    3, 4, 0, 2, 8, 6, 1, 7, 9
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
            hintCell: 40,
            expectedValue: 5
        ),
        PracticePuzzle(
            technique: .hiddenSingle,
            title: "Hidden Single in Column",
            description: "In Column 5, where can the number 1 go? Check each cell's constraints.",
            puzzle: Puzzle(
                difficulty: .easy,
                initialBoard: [
                    5, 3, 4, 6, 7, 8, 9, 0, 2,
                    6, 7, 2, 0, 9, 5, 3, 4, 8,
                    0, 9, 8, 3, 4, 2, 5, 6, 7,
                    8, 5, 9, 7, 6, 0, 4, 2, 3,
                    4, 2, 6, 8, 5, 3, 7, 9, 0,
                    7, 0, 3, 9, 2, 4, 8, 5, 6,
                    9, 6, 0, 5, 3, 7, 2, 8, 4,
                    2, 8, 7, 4, 0, 9, 6, 3, 5,  // R8C5 = 1 (hidden in column)
                    3, 4, 5, 2, 8, 6, 0, 7, 9
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
            hintCell: 67,
            expectedValue: 1
        )
    ]

    // MARK: - Naked Pair Examples

    let nakedPairPuzzles: [PracticePuzzle] = [
        PracticePuzzle(
            technique: .nakedPair,
            title: "Spot the Naked Pair",
            description: "Find two cells in the same row with identical candidates {3,7}. What can you eliminate?",
            puzzle: Puzzle(
                difficulty: .medium,
                initialBoard: [
                    0, 0, 0, 0, 5, 6, 0, 8, 9,  // Cells have 3,7 pair
                    4, 5, 6, 0, 8, 9, 1, 2, 0,
                    0, 8, 9, 1, 2, 0, 4, 5, 6,
                    2, 1, 4, 0, 6, 5, 8, 9, 0,
                    0, 6, 5, 8, 9, 0, 2, 1, 4,
                    8, 9, 0, 2, 1, 4, 0, 6, 5,
                    5, 0, 1, 6, 4, 2, 9, 0, 8,
                    6, 4, 2, 9, 0, 8, 5, 0, 1,
                    9, 0, 8, 5, 0, 1, 6, 4, 2
                ],
                solution: [
                    1, 2, 3, 4, 5, 6, 7, 8, 9,
                    4, 5, 6, 7, 8, 9, 1, 2, 3,
                    7, 8, 9, 1, 2, 3, 4, 5, 6,
                    2, 1, 4, 3, 6, 5, 8, 9, 7,
                    3, 6, 5, 8, 9, 7, 2, 1, 4,
                    8, 9, 7, 2, 1, 4, 3, 6, 5,
                    5, 3, 1, 6, 4, 2, 9, 7, 8,
                    6, 4, 2, 9, 7, 8, 5, 3, 1,
                    9, 7, 8, 5, 3, 1, 6, 4, 2
                ]
            ),
            hintCell: 0,
            expectedValue: nil
        )
    ]

    // MARK: - Hidden Pair Examples

    let hiddenPairPuzzles: [PracticePuzzle] = [
        PracticePuzzle(
            technique: .hiddenPair,
            title: "Find the Hidden Pair",
            description: "In this row, two numbers only appear in two cells. Can you find them?",
            puzzle: Puzzle(
                difficulty: .medium,
                initialBoard: [
                    0, 0, 0, 4, 5, 6, 7, 8, 9,  // 1,2,3 compete; 1,2 form hidden pair
                    4, 5, 6, 7, 8, 9, 1, 2, 3,
                    7, 8, 9, 1, 2, 3, 4, 5, 6,
                    2, 1, 4, 3, 6, 5, 8, 9, 7,
                    3, 6, 5, 8, 9, 7, 2, 1, 4,
                    8, 9, 7, 2, 1, 4, 3, 6, 5,
                    5, 3, 1, 6, 4, 2, 9, 7, 8,
                    6, 4, 2, 9, 7, 8, 5, 3, 1,
                    9, 7, 8, 5, 3, 1, 6, 4, 2
                ],
                solution: [
                    1, 2, 3, 4, 5, 6, 7, 8, 9,
                    4, 5, 6, 7, 8, 9, 1, 2, 3,
                    7, 8, 9, 1, 2, 3, 4, 5, 6,
                    2, 1, 4, 3, 6, 5, 8, 9, 7,
                    3, 6, 5, 8, 9, 7, 2, 1, 4,
                    8, 9, 7, 2, 1, 4, 3, 6, 5,
                    5, 3, 1, 6, 4, 2, 9, 7, 8,
                    6, 4, 2, 9, 7, 8, 5, 3, 1,
                    9, 7, 8, 5, 3, 1, 6, 4, 2
                ]
            ),
            hintCell: 0,
            expectedValue: nil
        )
    ]

    // MARK: - Pointing Pair Examples

    let pointingPairPuzzles: [PracticePuzzle] = [
        PracticePuzzle(
            technique: .pointingPair,
            title: "Pointing Pair in Action",
            description: "In Box 1, a number can only go in one row. Use this to eliminate candidates outside the box.",
            puzzle: Puzzle(
                difficulty: .medium,
                initialBoard: [
                    0, 0, 0, 0, 5, 6, 7, 8, 0,  // Setup for pointing pair
                    0, 5, 6, 7, 8, 9, 1, 2, 3,
                    7, 8, 9, 1, 2, 3, 4, 5, 6,
                    2, 1, 4, 3, 6, 5, 8, 9, 7,
                    3, 6, 5, 8, 9, 7, 2, 1, 4,
                    8, 9, 7, 2, 1, 4, 3, 6, 5,
                    5, 3, 1, 6, 4, 2, 9, 7, 8,
                    6, 4, 2, 9, 7, 8, 5, 3, 1,
                    9, 7, 8, 5, 3, 1, 6, 4, 2
                ],
                solution: [
                    1, 2, 3, 4, 5, 6, 7, 8, 9,
                    4, 5, 6, 7, 8, 9, 1, 2, 3,
                    7, 8, 9, 1, 2, 3, 4, 5, 6,
                    2, 1, 4, 3, 6, 5, 8, 9, 7,
                    3, 6, 5, 8, 9, 7, 2, 1, 4,
                    8, 9, 7, 2, 1, 4, 3, 6, 5,
                    5, 3, 1, 6, 4, 2, 9, 7, 8,
                    6, 4, 2, 9, 7, 8, 5, 3, 1,
                    9, 7, 8, 5, 3, 1, 6, 4, 2
                ]
            ),
            hintCell: 0,
            expectedValue: nil
        )
    ]

    // MARK: - Box/Line Reduction Examples

    let boxLineReductionPuzzles: [PracticePuzzle] = [
        PracticePuzzle(
            technique: .boxLineReduction,
            title: "Box/Line Reduction",
            description: "In this row, a number is confined to one box. Eliminate it from other cells in that box.",
            puzzle: Puzzle(
                difficulty: .medium,
                initialBoard: [
                    0, 2, 3, 0, 5, 6, 7, 8, 9,
                    4, 5, 6, 7, 8, 9, 0, 2, 3,
                    7, 8, 9, 0, 2, 3, 4, 5, 6,
                    2, 0, 4, 3, 6, 5, 8, 9, 7,
                    3, 6, 5, 8, 9, 7, 2, 0, 4,
                    8, 9, 7, 2, 0, 4, 3, 6, 5,
                    5, 3, 0, 6, 4, 2, 9, 7, 8,
                    6, 4, 2, 9, 7, 8, 5, 3, 0,
                    9, 7, 8, 5, 3, 0, 6, 4, 2
                ],
                solution: [
                    1, 2, 3, 4, 5, 6, 7, 8, 9,
                    4, 5, 6, 7, 8, 9, 1, 2, 3,
                    7, 8, 9, 1, 2, 3, 4, 5, 6,
                    2, 1, 4, 3, 6, 5, 8, 9, 7,
                    3, 6, 5, 8, 9, 7, 2, 1, 4,
                    8, 9, 7, 2, 1, 4, 3, 6, 5,
                    5, 3, 1, 6, 4, 2, 9, 7, 8,
                    6, 4, 2, 9, 7, 8, 5, 3, 1,
                    9, 7, 8, 5, 3, 1, 6, 4, 2
                ]
            ),
            hintCell: 0,
            expectedValue: nil
        )
    ]

    // MARK: - X-Wing Examples

    let xWingPuzzles: [PracticePuzzle] = [
        PracticePuzzle(
            technique: .xWing,
            title: "Your First X-Wing",
            description: "Find the rectangular pattern where a number appears in exactly 2 cells in 2 rows, aligned in the same columns.",
            puzzle: Puzzle(
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
            hintCell: 0,
            expectedValue: nil
        )
    ]

    // MARK: - Access Methods

    func puzzles(for technique: TechniqueType) -> [PracticePuzzle] {
        switch technique {
        case .nakedSingle:
            return nakedSinglePuzzles
        case .hiddenSingle:
            return hiddenSinglePuzzles
        case .nakedPair:
            return nakedPairPuzzles
        case .hiddenPair:
            return hiddenPairPuzzles
        case .pointingPair:
            return pointingPairPuzzles
        case .boxLineReduction:
            return boxLineReductionPuzzles
        case .xWing:
            return xWingPuzzles
        default:
            return []
        }
    }

    var allPuzzles: [PracticePuzzle] {
        nakedSinglePuzzles + hiddenSinglePuzzles + nakedPairPuzzles +
        hiddenPairPuzzles + pointingPairPuzzles + boxLineReductionPuzzles + xWingPuzzles
    }

    /// Get puzzles grouped by technique
    var puzzlesByTechnique: [(technique: TechniqueType, puzzles: [PracticePuzzle])] {
        [
            (.nakedSingle, nakedSinglePuzzles),
            (.hiddenSingle, hiddenSinglePuzzles),
            (.nakedPair, nakedPairPuzzles),
            (.hiddenPair, hiddenPairPuzzles),
            (.pointingPair, pointingPairPuzzles),
            (.boxLineReduction, boxLineReductionPuzzles),
            (.xWing, xWingPuzzles)
        ].filter { !$0.puzzles.isEmpty }
    }
}
