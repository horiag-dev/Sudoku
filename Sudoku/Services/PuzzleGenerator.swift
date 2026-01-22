import Foundation

/// Generates Sudoku puzzles of varying difficulty
class PuzzleGenerator {

    /// Generates a puzzle of the specified difficulty
    static func generate(difficulty: Difficulty) -> Puzzle {
        // Generate a solved board
        let solution = PuzzleSolver.generateSolvedBoard()

        // Create puzzle by removing cells
        let puzzle = createPuzzle(from: solution, difficulty: difficulty)

        return Puzzle(
            difficulty: difficulty,
            initialBoard: puzzle,
            solution: solution
        )
    }

    /// Creates a puzzle by strategically removing cells from a solved board
    private static func createPuzzle(from solution: [Int], difficulty: Difficulty) -> [Int] {
        var puzzle = solution
        let targetGivens = difficulty.givenCellRange.randomElement() ?? difficulty.givenCellRange.lowerBound

        // Get indices in random order
        var indices = Array(0..<81).shuffled()

        while puzzle.filter({ $0 != 0 }).count > targetGivens && !indices.isEmpty {
            let index = indices.removeFirst()

            // Skip already empty cells
            if puzzle[index] == 0 { continue }

            // Try removing this cell
            let backup = puzzle[index]
            puzzle[index] = 0

            // Check if still has unique solution
            if !PuzzleSolver.hasUniqueSolution(puzzle) {
                // Restore the cell - can't remove it
                puzzle[index] = backup
            }
        }

        return puzzle
    }

    /// Generates multiple puzzles in batch (useful for pre-generating)
    static func generateBatch(count: Int, difficulty: Difficulty) -> [Puzzle] {
        (0..<count).map { _ in generate(difficulty: difficulty) }
    }

    // MARK: - Difficulty Assessment

    /// Estimates the difficulty of a puzzle based on techniques needed
    static func assessDifficulty(_ puzzle: [Int]) -> Difficulty {
        let emptyCells = puzzle.filter { $0 == 0 }.count

        // Simple heuristic based on empty cell count
        if emptyCells <= 45 {
            return .easy
        } else if emptyCells <= 51 {
            return .medium
        } else {
            return .hard
        }
    }

    /// Checks if puzzle can be solved with only naked/hidden singles
    static func isSolvableWithSinglesOnly(_ puzzle: [Int]) -> Bool {
        var board = puzzle
        var progress = true

        while progress {
            progress = false

            for i in 0..<81 {
                if board[i] != 0 { continue }

                let candidates = PuzzleSolver.getCandidates(for: board, at: i)

                // Naked single
                if candidates.count == 1 {
                    board[i] = candidates.first!
                    progress = true
                    continue
                }

                // Hidden single in row
                let row = i / 9
                for candidate in candidates {
                    var isHidden = true
                    for col in 0..<9 {
                        let idx = row * 9 + col
                        if idx != i && board[idx] == 0 {
                            let otherCandidates = PuzzleSolver.getCandidates(for: board, at: idx)
                            if otherCandidates.contains(candidate) {
                                isHidden = false
                                break
                            }
                        }
                    }
                    if isHidden {
                        board[i] = candidate
                        progress = true
                        break
                    }
                }

                if board[i] != 0 { continue }

                // Hidden single in column
                let col = i % 9
                for candidate in candidates {
                    var isHidden = true
                    for r in 0..<9 {
                        let idx = r * 9 + col
                        if idx != i && board[idx] == 0 {
                            let otherCandidates = PuzzleSolver.getCandidates(for: board, at: idx)
                            if otherCandidates.contains(candidate) {
                                isHidden = false
                                break
                            }
                        }
                    }
                    if isHidden {
                        board[i] = candidate
                        progress = true
                        break
                    }
                }

                if board[i] != 0 { continue }

                // Hidden single in box
                let boxRow = (row / 3) * 3
                let boxCol = (col / 3) * 3
                for candidate in candidates {
                    var isHidden = true
                    outer: for r in boxRow..<boxRow + 3 {
                        for c in boxCol..<boxCol + 3 {
                            let idx = r * 9 + c
                            if idx != i && board[idx] == 0 {
                                let otherCandidates = PuzzleSolver.getCandidates(for: board, at: idx)
                                if otherCandidates.contains(candidate) {
                                    isHidden = false
                                    break outer
                                }
                            }
                        }
                    }
                    if isHidden {
                        board[i] = candidate
                        progress = true
                        break
                    }
                }
            }
        }

        return !board.contains(0)
    }
}
