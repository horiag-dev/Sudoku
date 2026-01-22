import Foundation

/// Detects applicable solving techniques on the current board
class TechniqueDetector {

    /// Finds all applicable techniques on the board
    static func findTechniques(on board: Board) -> [TechniqueHint] {
        var hints: [TechniqueHint] = []

        // Get candidates for all empty cells
        let boardArray = board.toArray()

        // Try to find techniques in order of difficulty
        if let hint = findNakedSingle(board: boardArray) {
            hints.append(hint)
        }

        if let hint = findHiddenSingle(board: boardArray) {
            hints.append(hint)
        }

        hints.append(contentsOf: findNakedPairs(board: boardArray))
        hints.append(contentsOf: findPointingPairs(board: boardArray))

        return hints
    }

    /// Find the best hint (simplest technique) for the current position
    static func findBestHint(on board: Board) -> TechniqueHint? {
        let boardArray = board.toArray()

        // Try techniques in order of difficulty
        if let hint = findNakedSingle(board: boardArray) {
            return hint
        }

        if let hint = findHiddenSingle(board: boardArray) {
            return hint
        }

        if let hint = findNakedPairs(board: boardArray).first {
            return hint
        }

        if let hint = findPointingPairs(board: boardArray).first {
            return hint
        }

        return nil
    }

    // MARK: - Naked Single

    static func findNakedSingle(board: [Int]) -> TechniqueHint? {
        for i in 0..<81 {
            if board[i] != 0 { continue }

            let candidates = PuzzleSolver.getCandidates(for: board, at: i)
            if candidates.count == 1 {
                let value = candidates.first!
                return TechniqueHint(
                    technique: .nakedSingle,
                    affectedCells: [i],
                    eliminationCells: [],
                    candidates: candidates,
                    explanation: "Cell R\(i/9 + 1)C\(i%9 + 1) can only be \(value) - all other numbers are already in the same row, column, or box."
                )
            }
        }
        return nil
    }

    // MARK: - Hidden Single

    static func findHiddenSingle(board: [Int]) -> TechniqueHint? {
        // Check rows
        for row in 0..<9 {
            if let hint = findHiddenSingleInUnit(board: board, indices: (0..<9).map { row * 9 + $0 }, unitName: "row \(row + 1)") {
                return hint
            }
        }

        // Check columns
        for col in 0..<9 {
            if let hint = findHiddenSingleInUnit(board: board, indices: (0..<9).map { $0 * 9 + col }, unitName: "column \(col + 1)") {
                return hint
            }
        }

        // Check boxes
        for box in 0..<9 {
            let startRow = (box / 3) * 3
            let startCol = (box % 3) * 3
            var indices: [Int] = []
            for r in startRow..<startRow + 3 {
                for c in startCol..<startCol + 3 {
                    indices.append(r * 9 + c)
                }
            }
            if let hint = findHiddenSingleInUnit(board: board, indices: indices, unitName: "box \(box + 1)") {
                return hint
            }
        }

        return nil
    }

    private static func findHiddenSingleInUnit(board: [Int], indices: [Int], unitName: String) -> TechniqueHint? {
        // For each number 1-9, count where it can go in this unit
        for num in 1...9 {
            var possibleCells: [Int] = []

            for index in indices {
                if board[index] == 0 {
                    let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                    if candidates.contains(num) {
                        possibleCells.append(index)
                    }
                } else if board[index] == num {
                    possibleCells = [] // Already placed
                    break
                }
            }

            if possibleCells.count == 1 {
                let cellIndex = possibleCells[0]
                return TechniqueHint(
                    technique: .hiddenSingle,
                    affectedCells: [cellIndex],
                    eliminationCells: [],
                    candidates: [num],
                    explanation: "In \(unitName), \(num) can only go in cell R\(cellIndex/9 + 1)C\(cellIndex%9 + 1)."
                )
            }
        }

        return nil
    }

    // MARK: - Naked Pairs

    static func findNakedPairs(board: [Int]) -> [TechniqueHint] {
        var hints: [TechniqueHint] = []

        // Helper to find naked pairs in a unit
        func findInUnit(indices: [Int], unitName: String) {
            // Find cells with exactly 2 candidates
            var twoCandidateCells: [(index: Int, candidates: Set<Int>)] = []

            for index in indices {
                if board[index] == 0 {
                    let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                    if candidates.count == 2 {
                        twoCandidateCells.append((index, candidates))
                    }
                }
            }

            // Check for pairs
            for i in 0..<twoCandidateCells.count {
                for j in (i+1)..<twoCandidateCells.count {
                    if twoCandidateCells[i].candidates == twoCandidateCells[j].candidates {
                        let pairCells = [twoCandidateCells[i].index, twoCandidateCells[j].index]
                        let pairCandidates = twoCandidateCells[i].candidates

                        // Find elimination cells
                        var eliminationCells: [Int] = []
                        for index in indices {
                            if board[index] == 0 && !pairCells.contains(index) {
                                let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                                if !candidates.isDisjoint(with: pairCandidates) {
                                    eliminationCells.append(index)
                                }
                            }
                        }

                        if !eliminationCells.isEmpty {
                            let nums = Array(pairCandidates).sorted()
                            hints.append(TechniqueHint(
                                technique: .nakedPair,
                                affectedCells: pairCells,
                                eliminationCells: eliminationCells,
                                candidates: pairCandidates,
                                explanation: "Cells R\(pairCells[0]/9 + 1)C\(pairCells[0]%9 + 1) and R\(pairCells[1]/9 + 1)C\(pairCells[1]%9 + 1) in \(unitName) form a naked pair with \(nums[0]) and \(nums[1]). These candidates can be eliminated from other cells in the \(unitName)."
                            ))
                        }
                    }
                }
            }
        }

        // Check all rows
        for row in 0..<9 {
            findInUnit(indices: (0..<9).map { row * 9 + $0 }, unitName: "row \(row + 1)")
        }

        // Check all columns
        for col in 0..<9 {
            findInUnit(indices: (0..<9).map { $0 * 9 + col }, unitName: "column \(col + 1)")
        }

        // Check all boxes
        for box in 0..<9 {
            let startRow = (box / 3) * 3
            let startCol = (box % 3) * 3
            var indices: [Int] = []
            for r in startRow..<startRow + 3 {
                for c in startCol..<startCol + 3 {
                    indices.append(r * 9 + c)
                }
            }
            findInUnit(indices: indices, unitName: "box \(box + 1)")
        }

        return hints
    }

    // MARK: - Pointing Pairs

    static func findPointingPairs(board: [Int]) -> [TechniqueHint] {
        var hints: [TechniqueHint] = []

        for box in 0..<9 {
            let boxStartRow = (box / 3) * 3
            let boxStartCol = (box % 3) * 3

            for num in 1...9 {
                // Find cells in this box where num can go
                var possibleCells: [Int] = []

                for r in boxStartRow..<boxStartRow + 3 {
                    for c in boxStartCol..<boxStartCol + 3 {
                        let index = r * 9 + c
                        if board[index] == 0 {
                            let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                            if candidates.contains(num) {
                                possibleCells.append(index)
                            }
                        }
                    }
                }

                if possibleCells.count >= 2 && possibleCells.count <= 3 {
                    // Check if all in same row
                    let rows = Set(possibleCells.map { $0 / 9 })
                    if rows.count == 1 {
                        let row = rows.first!
                        // Find elimination cells (same row, outside box)
                        var eliminationCells: [Int] = []
                        for c in 0..<9 {
                            if c < boxStartCol || c >= boxStartCol + 3 {
                                let index = row * 9 + c
                                if board[index] == 0 {
                                    let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                                    if candidates.contains(num) {
                                        eliminationCells.append(index)
                                    }
                                }
                            }
                        }

                        if !eliminationCells.isEmpty {
                            hints.append(TechniqueHint(
                                technique: .pointingPair,
                                affectedCells: possibleCells,
                                eliminationCells: eliminationCells,
                                candidates: [num],
                                explanation: "In box \(box + 1), \(num) is restricted to row \(row + 1). It can be eliminated from other cells in that row."
                            ))
                        }
                    }

                    // Check if all in same column
                    let cols = Set(possibleCells.map { $0 % 9 })
                    if cols.count == 1 {
                        let col = cols.first!
                        // Find elimination cells (same col, outside box)
                        var eliminationCells: [Int] = []
                        for r in 0..<9 {
                            if r < boxStartRow || r >= boxStartRow + 3 {
                                let index = r * 9 + col
                                if board[index] == 0 {
                                    let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                                    if candidates.contains(num) {
                                        eliminationCells.append(index)
                                    }
                                }
                            }
                        }

                        if !eliminationCells.isEmpty {
                            hints.append(TechniqueHint(
                                technique: .pointingPair,
                                affectedCells: possibleCells,
                                eliminationCells: eliminationCells,
                                candidates: [num],
                                explanation: "In box \(box + 1), \(num) is restricted to column \(col + 1). It can be eliminated from other cells in that column."
                            ))
                        }
                    }
                }
            }
        }

        return hints
    }
}
