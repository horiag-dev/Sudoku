import Foundation

/// Solves Sudoku puzzles using backtracking algorithm
class PuzzleSolver {

    // MARK: - Solving

    /// Solves a puzzle and returns the solution, or nil if unsolvable
    static func solve(_ puzzle: [Int]) -> [Int]? {
        var board = puzzle
        if solveBacktrack(&board) {
            return board
        }
        return nil
    }

    /// Backtracking solver - modifies board in place
    private static func solveBacktrack(_ board: inout [Int]) -> Bool {
        // Find next empty cell
        guard let emptyIndex = board.firstIndex(of: 0) else {
            return true // All cells filled, puzzle solved
        }

        let row = emptyIndex / 9
        let col = emptyIndex % 9

        // Try each number 1-9
        for num in 1...9 {
            if isValid(board, row: row, col: col, num: num) {
                board[emptyIndex] = num

                if solveBacktrack(&board) {
                    return true
                }

                board[emptyIndex] = 0 // Backtrack
            }
        }

        return false
    }

    /// Check if placing num at (row, col) is valid
    static func isValid(_ board: [Int], row: Int, col: Int, num: Int) -> Bool {
        // Check row
        for c in 0..<9 {
            if board[row * 9 + c] == num {
                return false
            }
        }

        // Check column
        for r in 0..<9 {
            if board[r * 9 + col] == num {
                return false
            }
        }

        // Check 3x3 box
        let boxRow = (row / 3) * 3
        let boxCol = (col / 3) * 3
        for r in boxRow..<boxRow + 3 {
            for c in boxCol..<boxCol + 3 {
                if board[r * 9 + c] == num {
                    return false
                }
            }
        }

        return true
    }

    // MARK: - Solution Counting

    /// Counts the number of solutions (stops at 2 to check for uniqueness)
    static func countSolutions(_ puzzle: [Int], limit: Int = 2) -> Int {
        var board = puzzle
        var count = 0
        countSolutionsHelper(&board, &count, limit: limit)
        return count
    }

    private static func countSolutionsHelper(_ board: inout [Int], _ count: inout Int, limit: Int) {
        if count >= limit { return }

        guard let emptyIndex = board.firstIndex(of: 0) else {
            count += 1
            return
        }

        let row = emptyIndex / 9
        let col = emptyIndex % 9

        for num in 1...9 {
            if isValid(board, row: row, col: col, num: num) {
                board[emptyIndex] = num
                countSolutionsHelper(&board, &count, limit: limit)
                board[emptyIndex] = 0
            }
        }
    }

    /// Returns true if puzzle has exactly one solution
    static func hasUniqueSolution(_ puzzle: [Int]) -> Bool {
        countSolutions(puzzle, limit: 2) == 1
    }

    // MARK: - Board Generation

    /// Generates a fully solved valid Sudoku board
    static func generateSolvedBoard() -> [Int] {
        var board = [Int](repeating: 0, count: 81)

        // Fill diagonal boxes first (they don't affect each other)
        fillDiagonalBoxes(&board)

        // Solve the rest
        _ = solveBacktrack(&board)

        return board
    }

    private static func fillDiagonalBoxes(_ board: inout [Int]) {
        for box in [0, 4, 8] { // Diagonal boxes
            let boxRow = (box / 3) * 3
            let boxCol = (box % 3) * 3
            var nums = Array(1...9).shuffled()

            for r in boxRow..<boxRow + 3 {
                for c in boxCol..<boxCol + 3 {
                    board[r * 9 + c] = nums.removeLast()
                }
            }
        }
    }

    // MARK: - Validation

    /// Checks if a completed board is valid
    static func isValidSolution(_ board: [Int]) -> Bool {
        // Check all cells are filled
        guard !board.contains(0) else { return false }

        // Check rows
        for row in 0..<9 {
            var seen = Set<Int>()
            for col in 0..<9 {
                let num = board[row * 9 + col]
                if seen.contains(num) { return false }
                seen.insert(num)
            }
        }

        // Check columns
        for col in 0..<9 {
            var seen = Set<Int>()
            for row in 0..<9 {
                let num = board[row * 9 + col]
                if seen.contains(num) { return false }
                seen.insert(num)
            }
        }

        // Check boxes
        for boxRow in stride(from: 0, to: 9, by: 3) {
            for boxCol in stride(from: 0, to: 9, by: 3) {
                var seen = Set<Int>()
                for r in boxRow..<boxRow + 3 {
                    for c in boxCol..<boxCol + 3 {
                        let num = board[r * 9 + c]
                        if seen.contains(num) { return false }
                        seen.insert(num)
                    }
                }
            }
        }

        return true
    }

    // MARK: - Candidates

    /// Returns possible candidates for a cell
    static func getCandidates(for board: [Int], at index: Int) -> Set<Int> {
        guard board[index] == 0 else { return [] }

        let row = index / 9
        let col = index % 9
        var candidates = Set(1...9)

        // Remove numbers in same row
        for c in 0..<9 {
            candidates.remove(board[row * 9 + c])
        }

        // Remove numbers in same column
        for r in 0..<9 {
            candidates.remove(board[r * 9 + col])
        }

        // Remove numbers in same box
        let boxRow = (row / 3) * 3
        let boxCol = (col / 3) * 3
        for r in boxRow..<boxRow + 3 {
            for c in boxCol..<boxCol + 3 {
                candidates.remove(board[r * 9 + c])
            }
        }

        return candidates
    }

    /// Returns all candidates for all empty cells
    static func getAllCandidates(for board: [Int]) -> [[Int]: Set<Int>] {
        var result: [[Int]: Set<Int>] = [:]
        for i in 0..<81 where board[i] == 0 {
            let row = i / 9
            let col = i % 9
            result[[row, col]] = getCandidates(for: board, at: i)
        }
        return result
    }
}
