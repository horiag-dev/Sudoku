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
        // Basic techniques
        if let hint = findNakedSingle(board: boardArray) {
            return hint
        }

        if let hint = findHiddenSingle(board: boardArray) {
            return hint
        }

        // Intermediate techniques
        if let hint = findNakedPairs(board: boardArray).first {
            return hint
        }

        if let hint = findHiddenPairs(board: boardArray).first {
            return hint
        }

        if let hint = findPointingPairs(board: boardArray).first {
            return hint
        }

        if let hint = findBoxLineReduction(board: boardArray).first {
            return hint
        }

        // Advanced techniques
        if let hint = findXWing(board: boardArray).first {
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
                let row = i / 9
                let col = i % 9
                let cellName = "R\(row + 1)C\(col + 1)"

                // Build detailed explanation showing what eliminates each number
                let (rowNums, colNums, boxNums) = getEliminatingNumbers(board: board, index: i)

                var steps: [HintStep] = []

                // Step 1: Identify the cell
                steps.append(HintStep(
                    title: "Look at cell \(cellName)",
                    explanation: "This cell is empty. Let's figure out what number can go here by checking what's NOT possible.",
                    highlightCells: [i],
                    emoji: "🔍"
                ))

                // Step 2: Check the row
                if !rowNums.isEmpty {
                    let rowNumStr = rowNums.sorted().map { String($0) }.joined(separator: ", ")
                    steps.append(HintStep(
                        title: "Check Row \(row + 1)",
                        explanation: "Looking across this row, we already have: \(rowNumStr). So our cell can't be any of these numbers.",
                        highlightCells: getRowIndices(row: row),
                        emoji: "➡️"
                    ))
                }

                // Step 3: Check the column
                if !colNums.isEmpty {
                    let colNumStr = colNums.sorted().map { String($0) }.joined(separator: ", ")
                    steps.append(HintStep(
                        title: "Check Column \(col + 1)",
                        explanation: "Looking down this column, we already have: \(colNumStr). These are also ruled out.",
                        highlightCells: getColIndices(col: col),
                        emoji: "⬇️"
                    ))
                }

                // Step 4: Check the box
                if !boxNums.isEmpty {
                    let boxNumStr = boxNums.sorted().map { String($0) }.joined(separator: ", ")
                    let boxNumber = (row / 3) * 3 + (col / 3) + 1
                    steps.append(HintStep(
                        title: "Check Box \(boxNumber)",
                        explanation: "Looking at the 3×3 box, we already have: \(boxNumStr). These can't be repeated.",
                        highlightCells: getBoxIndices(row: row, col: col),
                        emoji: "🔲"
                    ))
                }

                // Step 5: The conclusion
                let allEliminated = Set(1...9).subtracting(candidates).sorted()
                steps.append(HintStep(
                    title: "Only one number left!",
                    explanation: "We've eliminated \(allEliminated.map { String($0) }.joined(separator: ", ")) from the possibilities. The ONLY number that can go in this cell is \(value).",
                    highlightCells: [i],
                    emoji: "✅"
                ))

                return TechniqueHint(
                    technique: .nakedSingle,
                    affectedCells: [i],
                    eliminationCells: [],
                    candidates: candidates,
                    explanation: "Cell \(cellName) can only be \(value). All other numbers (1-9) are already present in its row, column, or box.",
                    detailedSteps: steps
                )
            }
        }
        return nil
    }

    // Helper to get which numbers eliminate candidates from row, col, box
    private static func getEliminatingNumbers(board: [Int], index: Int) -> (row: Set<Int>, col: Set<Int>, box: Set<Int>) {
        let row = index / 9
        let col = index % 9
        var rowNums = Set<Int>()
        var colNums = Set<Int>()
        var boxNums = Set<Int>()

        // Row numbers
        for c in 0..<9 {
            let val = board[row * 9 + c]
            if val != 0 { rowNums.insert(val) }
        }

        // Column numbers
        for r in 0..<9 {
            let val = board[r * 9 + col]
            if val != 0 { colNums.insert(val) }
        }

        // Box numbers (excluding those already counted in row/col)
        let boxRow = (row / 3) * 3
        let boxCol = (col / 3) * 3
        for r in boxRow..<boxRow + 3 {
            for c in boxCol..<boxCol + 3 {
                let val = board[r * 9 + c]
                if val != 0 { boxNums.insert(val) }
            }
        }

        // Remove overlaps for cleaner explanation
        colNums.subtract(rowNums)
        boxNums.subtract(rowNums)
        boxNums.subtract(colNums)

        return (rowNums, colNums, boxNums)
    }

    private static func getRowIndices(row: Int) -> [Int] {
        (0..<9).map { row * 9 + $0 }
    }

    private static func getColIndices(col: Int) -> [Int] {
        (0..<9).map { $0 * 9 + col }
    }

    private static func getBoxIndices(row: Int, col: Int) -> [Int] {
        let boxRow = (row / 3) * 3
        let boxCol = (col / 3) * 3
        var indices: [Int] = []
        for r in boxRow..<boxRow + 3 {
            for c in boxCol..<boxCol + 3 {
                indices.append(r * 9 + c)
            }
        }
        return indices
    }

    // MARK: - Hidden Single

    static func findHiddenSingle(board: [Int]) -> TechniqueHint? {
        // Check rows first (usually easier to see)
        for row in 0..<9 {
            if let hint = findHiddenSingleInUnit(board: board, indices: (0..<9).map { row * 9 + $0 }, unitType: "row", unitNumber: row + 1) {
                return hint
            }
        }

        // Check columns
        for col in 0..<9 {
            if let hint = findHiddenSingleInUnit(board: board, indices: (0..<9).map { $0 * 9 + col }, unitType: "column", unitNumber: col + 1) {
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
            if let hint = findHiddenSingleInUnit(board: board, indices: indices, unitType: "box", unitNumber: box + 1) {
                return hint
            }
        }

        return nil
    }

    private static func findHiddenSingleInUnit(board: [Int], indices: [Int], unitType: String, unitNumber: Int) -> TechniqueHint? {
        let unitName = "\(unitType) \(unitNumber)"

        // For each number 1-9, find where it can go in this unit
        for num in 1...9 {
            var possibleCells: [Int] = []
            var alreadyPlaced = false

            for index in indices {
                if board[index] == num {
                    alreadyPlaced = true
                    break
                } else if board[index] == 0 {
                    let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                    if candidates.contains(num) {
                        possibleCells.append(index)
                    }
                }
            }

            if alreadyPlaced { continue }

            if possibleCells.count == 1 {
                let cellIndex = possibleCells[0]
                let row = cellIndex / 9
                let col = cellIndex % 9
                let cellName = "R\(row + 1)C\(col + 1)"

                // Build detailed steps explaining why this is the only place
                var steps: [HintStep] = []

                // Step 1: The question we're asking
                steps.append(HintStep(
                    title: "Where can \(num) go in \(unitName)?",
                    explanation: "Let's look at \(unitName) and figure out which cells could possibly contain the number \(num).",
                    highlightCells: indices,
                    emoji: "🤔"
                ))

                // Step 2: Analyze each cell in the unit
                var reasons: [String] = []
                for index in indices {
                    if index == cellIndex { continue }
                    let r = index / 9
                    let c = index % 9

                    if board[index] != 0 {
                        reasons.append("• R\(r+1)C\(c+1) already has \(board[index])")
                    } else {
                        let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                        if !candidates.contains(num) {
                            // Find out WHY this cell can't have num
                            let whyNot = explainWhyCantHaveNumber(board: board, index: index, num: num)
                            reasons.append("• R\(r+1)C\(c+1) can't be \(num) — \(whyNot)")
                        }
                    }
                }

                if !reasons.isEmpty {
                    let reasonText = reasons.prefix(4).joined(separator: "\n")
                    let moreText = reasons.count > 4 ? "\n• ...and \(reasons.count - 4) more cells are also blocked" : ""
                    steps.append(HintStep(
                        title: "Why other cells can't have \(num)",
                        explanation: "\(reasonText)\(moreText)",
                        highlightCells: indices.filter { $0 != cellIndex },
                        emoji: "🚫"
                    ))
                }

                // Step 3: The conclusion
                steps.append(HintStep(
                    title: "Only one place left!",
                    explanation: "Cell \(cellName) is the ONLY cell in \(unitName) where \(num) can go. Even though this cell might have other candidates, \(num) MUST go here because there's nowhere else in \(unitName) for it.",
                    highlightCells: [cellIndex],
                    emoji: "✅"
                ))

                return TechniqueHint(
                    technique: .hiddenSingle,
                    affectedCells: [cellIndex],
                    eliminationCells: [],
                    candidates: [num],
                    explanation: "In \(unitName), the number \(num) can only go in cell \(cellName). All other cells in \(unitName) are either filled or can't contain \(num) due to conflicts.",
                    detailedSteps: steps
                )
            }
        }

        return nil
    }

    /// Explains why a cell cannot contain a specific number
    private static func explainWhyCantHaveNumber(board: [Int], index: Int, num: Int) -> String {
        let row = index / 9
        let col = index % 9

        // Check row for the number
        for c in 0..<9 {
            if board[row * 9 + c] == num {
                return "\(num) is already in row \(row + 1)"
            }
        }

        // Check column for the number
        for r in 0..<9 {
            if board[r * 9 + col] == num {
                return "\(num) is already in column \(col + 1)"
            }
        }

        // Check box for the number
        let boxRow = (row / 3) * 3
        let boxCol = (col / 3) * 3
        for r in boxRow..<boxRow + 3 {
            for c in boxCol..<boxCol + 3 {
                if board[r * 9 + c] == num {
                    let boxNum = (boxRow / 3) * 3 + (boxCol / 3) + 1
                    return "\(num) is already in box \(boxNum)"
                }
            }
        }

        return "blocked by row, column, or box"
    }

    // MARK: - Naked Pairs

    static func findNakedPairs(board: [Int]) -> [TechniqueHint] {
        var hints: [TechniqueHint] = []

        // Helper to find naked pairs in a unit
        func findInUnit(indices: [Int], unitType: String, unitNumber: Int) {
            let unitName = "\(unitType) \(unitNumber)"

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
                        let nums = Array(pairCandidates).sorted()

                        let cell1 = pairCells[0]
                        let cell2 = pairCells[1]
                        let cell1Name = "R\(cell1/9 + 1)C\(cell1%9 + 1)"
                        let cell2Name = "R\(cell2/9 + 1)C\(cell2%9 + 1)"

                        // Find elimination cells and what gets eliminated
                        var eliminationCells: [Int] = []
                        var eliminationDetails: [(cell: Int, candidates: Set<Int>)] = []

                        for index in indices {
                            if board[index] == 0 && !pairCells.contains(index) {
                                let cellCandidates = PuzzleSolver.getCandidates(for: board, at: index)
                                let overlap = cellCandidates.intersection(pairCandidates)
                                if !overlap.isEmpty {
                                    eliminationCells.append(index)
                                    eliminationDetails.append((index, overlap))
                                }
                            }
                        }

                        if !eliminationCells.isEmpty {
                            var steps: [HintStep] = []

                            // Step 1: Find the pair
                            steps.append(HintStep(
                                title: "Spot the pair",
                                explanation: "Look at cells \(cell1Name) and \(cell2Name) in \(unitName). Both cells have exactly the same two candidates: \(nums[0]) and \(nums[1]). Nothing else can go in either cell.",
                                highlightCells: pairCells,
                                emoji: "👀"
                            ))

                            // Step 2: Explain the logic
                            steps.append(HintStep(
                                title: "Think about what this means",
                                explanation: "Since \(cell1Name) can ONLY be \(nums[0]) or \(nums[1]), and \(cell2Name) can ONLY be \(nums[0]) or \(nums[1]), these two numbers are \"locked\" into these two cells. One cell will be \(nums[0]), the other will be \(nums[1]) — we just don't know which is which yet.",
                                highlightCells: pairCells,
                                emoji: "🔒"
                            ))

                            // Step 3: The key insight
                            steps.append(HintStep(
                                title: "The key insight",
                                explanation: "Because \(nums[0]) and \(nums[1]) MUST go in these two cells, no OTHER cell in \(unitName) can contain \(nums[0]) or \(nums[1]). They're \"claimed\" by the pair!",
                                highlightCells: pairCells,
                                emoji: "💡"
                            ))

                            // Step 4: Show what gets eliminated
                            var elimExplanations: [String] = []
                            for detail in eliminationDetails {
                                let cellName = "R\(detail.cell/9 + 1)C\(detail.cell%9 + 1)"
                                let elimNums = detail.candidates.sorted().map { String($0) }.joined(separator: " and ")
                                elimExplanations.append("• \(cellName): remove \(elimNums)")
                            }

                            steps.append(HintStep(
                                title: "Eliminate candidates",
                                explanation: "We can remove \(nums[0]) and \(nums[1]) from other cells in \(unitName):\n\(elimExplanations.joined(separator: "\n"))",
                                highlightCells: eliminationCells,
                                emoji: "✂️"
                            ))

                            hints.append(TechniqueHint(
                                technique: .nakedPair,
                                affectedCells: pairCells,
                                eliminationCells: eliminationCells,
                                candidates: pairCandidates,
                                explanation: "Cells \(cell1Name) and \(cell2Name) both contain only \(nums[0]) and \(nums[1]). These two numbers must go in these two cells, so they can be eliminated from other cells in \(unitName).",
                                detailedSteps: steps
                            ))
                        }
                    }
                }
            }
        }

        // Check all rows
        for row in 0..<9 {
            findInUnit(indices: (0..<9).map { row * 9 + $0 }, unitType: "row", unitNumber: row + 1)
        }

        // Check all columns
        for col in 0..<9 {
            findInUnit(indices: (0..<9).map { $0 * 9 + col }, unitType: "column", unitNumber: col + 1)
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
            findInUnit(indices: indices, unitType: "box", unitNumber: box + 1)
        }

        return hints
    }

    // MARK: - Pointing Pairs

    static func findPointingPairs(board: [Int]) -> [TechniqueHint] {
        var hints: [TechniqueHint] = []

        for box in 0..<9 {
            let boxStartRow = (box / 3) * 3
            let boxStartCol = (box % 3) * 3
            let boxNumber = box + 1

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
                            let cellNames = possibleCells.map { "R\($0/9 + 1)C\($0%9 + 1)" }.joined(separator: ", ")
                            let elimCellNames = eliminationCells.map { "R\($0/9 + 1)C\($0%9 + 1)" }.joined(separator: ", ")

                            var steps: [HintStep] = []

                            // Step 1: Look at the box
                            steps.append(HintStep(
                                title: "Where can \(num) go in Box \(boxNumber)?",
                                explanation: "Let's find all the places where \(num) could possibly go within Box \(boxNumber).",
                                highlightCells: getBoxIndicesForBox(box: box),
                                emoji: "🔍"
                            ))

                            // Step 2: Notice the pattern
                            steps.append(HintStep(
                                title: "Notice something special",
                                explanation: "In Box \(boxNumber), the number \(num) can only go in cells \(cellNames). Look at these cells — they're ALL in Row \(row + 1)!",
                                highlightCells: possibleCells,
                                emoji: "👀"
                            ))

                            // Step 3: The logic
                            steps.append(HintStep(
                                title: "Think about Row \(row + 1)",
                                explanation: "Row \(row + 1) needs a \(num) somewhere. We just discovered that within Box \(boxNumber), \(num) can ONLY be in Row \(row + 1). This means Row \(row + 1)'s \(num) MUST come from Box \(boxNumber).",
                                highlightCells: getRowIndices(row: row),
                                emoji: "💡"
                            ))

                            // Step 4: The elimination
                            steps.append(HintStep(
                                title: "Eliminate outside the box",
                                explanation: "Since Row \(row + 1)'s \(num) must be in Box \(boxNumber), cells in Row \(row + 1) that are OUTSIDE Box \(boxNumber) cannot contain \(num). Remove \(num) from: \(elimCellNames)",
                                highlightCells: eliminationCells,
                                emoji: "✂️"
                            ))

                            hints.append(TechniqueHint(
                                technique: .pointingPair,
                                affectedCells: possibleCells,
                                eliminationCells: eliminationCells,
                                candidates: [num],
                                explanation: "In Box \(boxNumber), the number \(num) can only appear in Row \(row + 1). This means \(num) can be eliminated from Row \(row + 1) cells outside Box \(boxNumber).",
                                detailedSteps: steps
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
                            let cellNames = possibleCells.map { "R\($0/9 + 1)C\($0%9 + 1)" }.joined(separator: ", ")
                            let elimCellNames = eliminationCells.map { "R\($0/9 + 1)C\($0%9 + 1)" }.joined(separator: ", ")

                            var steps: [HintStep] = []

                            // Step 1: Look at the box
                            steps.append(HintStep(
                                title: "Where can \(num) go in Box \(boxNumber)?",
                                explanation: "Let's find all the places where \(num) could possibly go within Box \(boxNumber).",
                                highlightCells: getBoxIndicesForBox(box: box),
                                emoji: "🔍"
                            ))

                            // Step 2: Notice the pattern
                            steps.append(HintStep(
                                title: "Notice something special",
                                explanation: "In Box \(boxNumber), the number \(num) can only go in cells \(cellNames). Look at these cells — they're ALL in Column \(col + 1)!",
                                highlightCells: possibleCells,
                                emoji: "👀"
                            ))

                            // Step 3: The logic
                            steps.append(HintStep(
                                title: "Think about Column \(col + 1)",
                                explanation: "Column \(col + 1) needs a \(num) somewhere. We just discovered that within Box \(boxNumber), \(num) can ONLY be in Column \(col + 1). This means Column \(col + 1)'s \(num) MUST come from Box \(boxNumber).",
                                highlightCells: getColIndices(col: col),
                                emoji: "💡"
                            ))

                            // Step 4: The elimination
                            steps.append(HintStep(
                                title: "Eliminate outside the box",
                                explanation: "Since Column \(col + 1)'s \(num) must be in Box \(boxNumber), cells in Column \(col + 1) that are OUTSIDE Box \(boxNumber) cannot contain \(num). Remove \(num) from: \(elimCellNames)",
                                highlightCells: eliminationCells,
                                emoji: "✂️"
                            ))

                            hints.append(TechniqueHint(
                                technique: .pointingPair,
                                affectedCells: possibleCells,
                                eliminationCells: eliminationCells,
                                candidates: [num],
                                explanation: "In Box \(boxNumber), the number \(num) can only appear in Column \(col + 1). This means \(num) can be eliminated from Column \(col + 1) cells outside Box \(boxNumber).",
                                detailedSteps: steps
                            ))
                        }
                    }
                }
            }
        }

        return hints
    }

    private static func getBoxIndicesForBox(box: Int) -> [Int] {
        let boxStartRow = (box / 3) * 3
        let boxStartCol = (box % 3) * 3
        var indices: [Int] = []
        for r in boxStartRow..<boxStartRow + 3 {
            for c in boxStartCol..<boxStartCol + 3 {
                indices.append(r * 9 + c)
            }
        }
        return indices
    }

    // MARK: - Hidden Pairs

    static func findHiddenPairs(board: [Int]) -> [TechniqueHint] {
        var hints: [TechniqueHint] = []

        func findInUnit(indices: [Int], unitType: String, unitNumber: Int) {
            let unitName = "\(unitType) \(unitNumber)"

            // For each pair of numbers, check if they appear in exactly 2 cells
            for num1 in 1...8 {
                for num2 in (num1+1)...9 {
                    var cellsWithNum1: [Int] = []
                    var cellsWithNum2: [Int] = []

                    for index in indices {
                        if board[index] == 0 {
                            let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                            if candidates.contains(num1) { cellsWithNum1.append(index) }
                            if candidates.contains(num2) { cellsWithNum2.append(index) }
                        }
                    }

                    // Hidden pair: both numbers appear in exactly the same 2 cells
                    if cellsWithNum1.count == 2 && cellsWithNum1 == cellsWithNum2 {
                        let pairCells = cellsWithNum1
                        let cell1 = pairCells[0]
                        let cell2 = pairCells[1]
                        let cell1Name = "R\(cell1/9 + 1)C\(cell1%9 + 1)"
                        let cell2Name = "R\(cell2/9 + 1)C\(cell2%9 + 1)"

                        // Check if there are other candidates to eliminate
                        let cell1Candidates = PuzzleSolver.getCandidates(for: board, at: cell1)
                        let cell2Candidates = PuzzleSolver.getCandidates(for: board, at: cell2)
                        let pairNums: Set<Int> = [num1, num2]

                        let cell1Extras = cell1Candidates.subtracting(pairNums)
                        let cell2Extras = cell2Candidates.subtracting(pairNums)

                        if !cell1Extras.isEmpty || !cell2Extras.isEmpty {
                            var steps: [HintStep] = []

                            // Step 1: Find where the numbers can go
                            steps.append(HintStep(
                                title: "Where can \(num1) and \(num2) go?",
                                explanation: "In \(unitName), let's look at where \(num1) and \(num2) can be placed. Both numbers can ONLY go in cells \(cell1Name) and \(cell2Name) — nowhere else in \(unitName)!",
                                highlightCells: pairCells,
                                emoji: "🔍"
                            ))

                            // Step 2: The hidden pair logic
                            steps.append(HintStep(
                                title: "This is a Hidden Pair",
                                explanation: "Since \(num1) and \(num2) can only go in these two cells, they MUST go in these cells. One cell gets \(num1), the other gets \(num2). These numbers are \"hiding\" among other candidates.",
                                highlightCells: pairCells,
                                emoji: "🙈"
                            ))

                            // Step 3: What we can eliminate
                            var elimDetails: [String] = []
                            if !cell1Extras.isEmpty {
                                elimDetails.append("\(cell1Name): remove \(cell1Extras.sorted().map{String($0)}.joined(separator: ", "))")
                            }
                            if !cell2Extras.isEmpty {
                                elimDetails.append("\(cell2Name): remove \(cell2Extras.sorted().map{String($0)}.joined(separator: ", "))")
                            }

                            steps.append(HintStep(
                                title: "Clear out the extras",
                                explanation: "Since these cells must contain \(num1) and \(num2), we can remove all OTHER candidates from them:\n• \(elimDetails.joined(separator: "\n• "))",
                                highlightCells: pairCells,
                                emoji: "✂️"
                            ))

                            hints.append(TechniqueHint(
                                technique: .hiddenPair,
                                affectedCells: pairCells,
                                eliminationCells: pairCells, // Eliminations happen IN the pair cells
                                candidates: pairNums,
                                explanation: "In \(unitName), \(num1) and \(num2) can only go in \(cell1Name) and \(cell2Name). Other candidates in these cells can be eliminated.",
                                detailedSteps: steps
                            ))
                        }
                    }
                }
            }
        }

        // Check all rows
        for row in 0..<9 {
            findInUnit(indices: (0..<9).map { row * 9 + $0 }, unitType: "row", unitNumber: row + 1)
        }

        // Check all columns
        for col in 0..<9 {
            findInUnit(indices: (0..<9).map { $0 * 9 + col }, unitType: "column", unitNumber: col + 1)
        }

        // Check all boxes
        for box in 0..<9 {
            findInUnit(indices: getBoxIndicesForBox(box: box), unitType: "box", unitNumber: box + 1)
        }

        return hints
    }

    // MARK: - Box/Line Reduction

    static func findBoxLineReduction(board: [Int]) -> [TechniqueHint] {
        var hints: [TechniqueHint] = []

        // Check each row
        for row in 0..<9 {
            for num in 1...9 {
                // Find cells in this row where num can go
                var possibleCells: [Int] = []
                for col in 0..<9 {
                    let index = row * 9 + col
                    if board[index] == 0 {
                        let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                        if candidates.contains(num) {
                            possibleCells.append(index)
                        }
                    }
                }

                if possibleCells.count >= 2 && possibleCells.count <= 3 {
                    // Check if all cells are in the same box
                    let boxes = Set(possibleCells.map { ($0 / 9 / 3) * 3 + ($0 % 9 / 3) })
                    if boxes.count == 1 {
                        let box = boxes.first!
                        let boxIndices = getBoxIndicesForBox(box: box)

                        // Find elimination cells (same box, different row)
                        var eliminationCells: [Int] = []
                        for index in boxIndices {
                            if index / 9 != row && board[index] == 0 {
                                let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                                if candidates.contains(num) {
                                    eliminationCells.append(index)
                                }
                            }
                        }

                        if !eliminationCells.isEmpty {
                            let cellNames = possibleCells.map { "R\($0/9 + 1)C\($0%9 + 1)" }.joined(separator: ", ")
                            let elimCellNames = eliminationCells.map { "R\($0/9 + 1)C\($0%9 + 1)" }.joined(separator: ", ")

                            var steps: [HintStep] = []

                            steps.append(HintStep(
                                title: "Where can \(num) go in Row \(row + 1)?",
                                explanation: "Looking at Row \(row + 1), the number \(num) can only go in cells \(cellNames).",
                                highlightCells: possibleCells,
                                emoji: "🔍"
                            ))

                            steps.append(HintStep(
                                title: "Notice the box alignment",
                                explanation: "All these cells are in Box \(box + 1)! This means Row \(row + 1)'s \(num) must be somewhere in Box \(box + 1).",
                                highlightCells: possibleCells,
                                emoji: "📦"
                            ))

                            steps.append(HintStep(
                                title: "Box/Line Reduction",
                                explanation: "Since Box \(box + 1) will get its \(num) from Row \(row + 1), the other rows in Box \(box + 1) can't have \(num). Remove \(num) from: \(elimCellNames)",
                                highlightCells: eliminationCells,
                                emoji: "✂️"
                            ))

                            hints.append(TechniqueHint(
                                technique: .boxLineReduction,
                                affectedCells: possibleCells,
                                eliminationCells: eliminationCells,
                                candidates: [num],
                                explanation: "In Row \(row + 1), \(num) is confined to Box \(box + 1). Other cells in Box \(box + 1) cannot contain \(num).",
                                detailedSteps: steps
                            ))
                        }
                    }
                }
            }
        }

        // Check each column (similar logic)
        for col in 0..<9 {
            for num in 1...9 {
                var possibleCells: [Int] = []
                for row in 0..<9 {
                    let index = row * 9 + col
                    if board[index] == 0 {
                        let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                        if candidates.contains(num) {
                            possibleCells.append(index)
                        }
                    }
                }

                if possibleCells.count >= 2 && possibleCells.count <= 3 {
                    let boxes = Set(possibleCells.map { ($0 / 9 / 3) * 3 + ($0 % 9 / 3) })
                    if boxes.count == 1 {
                        let box = boxes.first!
                        let boxIndices = getBoxIndicesForBox(box: box)

                        var eliminationCells: [Int] = []
                        for index in boxIndices {
                            if index % 9 != col && board[index] == 0 {
                                let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                                if candidates.contains(num) {
                                    eliminationCells.append(index)
                                }
                            }
                        }

                        if !eliminationCells.isEmpty {
                            let cellNames = possibleCells.map { "R\($0/9 + 1)C\($0%9 + 1)" }.joined(separator: ", ")
                            let elimCellNames = eliminationCells.map { "R\($0/9 + 1)C\($0%9 + 1)" }.joined(separator: ", ")

                            var steps: [HintStep] = []

                            steps.append(HintStep(
                                title: "Where can \(num) go in Column \(col + 1)?",
                                explanation: "Looking at Column \(col + 1), the number \(num) can only go in cells \(cellNames).",
                                highlightCells: possibleCells,
                                emoji: "🔍"
                            ))

                            steps.append(HintStep(
                                title: "Notice the box alignment",
                                explanation: "All these cells are in Box \(box + 1)! This means Column \(col + 1)'s \(num) must be somewhere in Box \(box + 1).",
                                highlightCells: possibleCells,
                                emoji: "📦"
                            ))

                            steps.append(HintStep(
                                title: "Box/Line Reduction",
                                explanation: "Since Box \(box + 1) will get its \(num) from Column \(col + 1), the other columns in Box \(box + 1) can't have \(num). Remove \(num) from: \(elimCellNames)",
                                highlightCells: eliminationCells,
                                emoji: "✂️"
                            ))

                            hints.append(TechniqueHint(
                                technique: .boxLineReduction,
                                affectedCells: possibleCells,
                                eliminationCells: eliminationCells,
                                candidates: [num],
                                explanation: "In Column \(col + 1), \(num) is confined to Box \(box + 1). Other cells in Box \(box + 1) cannot contain \(num).",
                                detailedSteps: steps
                            ))
                        }
                    }
                }
            }
        }

        return hints
    }

    // MARK: - X-Wing

    static func findXWing(board: [Int]) -> [TechniqueHint] {
        var hints: [TechniqueHint] = []

        for num in 1...9 {
            // Find rows where num appears in exactly 2 cells
            var rowsWithTwoCells: [(row: Int, cols: [Int])] = []

            for row in 0..<9 {
                var cols: [Int] = []
                for col in 0..<9 {
                    let index = row * 9 + col
                    if board[index] == 0 {
                        let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                        if candidates.contains(num) {
                            cols.append(col)
                        }
                    }
                }
                if cols.count == 2 {
                    rowsWithTwoCells.append((row, cols))
                }
            }

            // Look for X-Wing pattern (two rows with same two columns)
            for i in 0..<rowsWithTwoCells.count {
                for j in (i+1)..<rowsWithTwoCells.count {
                    if rowsWithTwoCells[i].cols == rowsWithTwoCells[j].cols {
                        let row1 = rowsWithTwoCells[i].row
                        let row2 = rowsWithTwoCells[j].row
                        let col1 = rowsWithTwoCells[i].cols[0]
                        let col2 = rowsWithTwoCells[i].cols[1]

                        let cornerCells = [
                            row1 * 9 + col1,
                            row1 * 9 + col2,
                            row2 * 9 + col1,
                            row2 * 9 + col2
                        ]

                        // Find elimination cells in the two columns (not in the X-Wing rows)
                        var eliminationCells: [Int] = []
                        for row in 0..<9 {
                            if row != row1 && row != row2 {
                                for col in [col1, col2] {
                                    let index = row * 9 + col
                                    if board[index] == 0 {
                                        let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                                        if candidates.contains(num) {
                                            eliminationCells.append(index)
                                        }
                                    }
                                }
                            }
                        }

                        if !eliminationCells.isEmpty {
                            let cornerNames = cornerCells.map { "R\($0/9 + 1)C\($0%9 + 1)" }
                            let elimCellNames = eliminationCells.map { "R\($0/9 + 1)C\($0%9 + 1)" }.joined(separator: ", ")

                            var steps: [HintStep] = []

                            steps.append(HintStep(
                                title: "Find the X-Wing pattern",
                                explanation: "Look at where \(num) can go in Row \(row1 + 1) and Row \(row2 + 1). In both rows, \(num) can only go in Column \(col1 + 1) or Column \(col2 + 1). This forms a rectangle!",
                                highlightCells: cornerCells,
                                emoji: "✈️"
                            ))

                            steps.append(HintStep(
                                title: "Understand the X-Wing logic",
                                explanation: "The four corners are: \(cornerNames.joined(separator: ", ")). In Row \(row1 + 1), \(num) goes in either Col \(col1 + 1) OR Col \(col2 + 1). The same for Row \(row2 + 1). This creates a linked pattern.",
                                highlightCells: cornerCells,
                                emoji: "🔗"
                            ))

                            steps.append(HintStep(
                                title: "The diagonal constraint",
                                explanation: "If \(num) is at R\(row1 + 1)C\(col1 + 1), then R\(row2 + 1) must have \(num) at C\(col2 + 1). Either way, both Column \(col1 + 1) AND Column \(col2 + 1) will have a \(num) from one of these two rows.",
                                highlightCells: cornerCells,
                                emoji: "💡"
                            ))

                            steps.append(HintStep(
                                title: "Eliminate from the columns",
                                explanation: "Since Columns \(col1 + 1) and \(col2 + 1) will get their \(num) from Row \(row1 + 1) or Row \(row2 + 1), all other cells in these columns can't have \(num). Remove from: \(elimCellNames)",
                                highlightCells: eliminationCells,
                                emoji: "✂️"
                            ))

                            hints.append(TechniqueHint(
                                technique: .xWing,
                                affectedCells: cornerCells,
                                eliminationCells: eliminationCells,
                                candidates: [num],
                                explanation: "X-Wing on \(num): Rows \(row1 + 1) and \(row2 + 1) both have \(num) limited to Columns \(col1 + 1) and \(col2 + 1). Eliminate \(num) from other cells in these columns.",
                                detailedSteps: steps
                            ))
                        }
                    }
                }
            }

            // Also check for column-based X-Wing
            var colsWithTwoCells: [(col: Int, rows: [Int])] = []

            for col in 0..<9 {
                var rows: [Int] = []
                for row in 0..<9 {
                    let index = row * 9 + col
                    if board[index] == 0 {
                        let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                        if candidates.contains(num) {
                            rows.append(row)
                        }
                    }
                }
                if rows.count == 2 {
                    colsWithTwoCells.append((col, rows))
                }
            }

            for i in 0..<colsWithTwoCells.count {
                for j in (i+1)..<colsWithTwoCells.count {
                    if colsWithTwoCells[i].rows == colsWithTwoCells[j].rows {
                        let col1 = colsWithTwoCells[i].col
                        let col2 = colsWithTwoCells[j].col
                        let row1 = colsWithTwoCells[i].rows[0]
                        let row2 = colsWithTwoCells[i].rows[1]

                        let cornerCells = [
                            row1 * 9 + col1,
                            row1 * 9 + col2,
                            row2 * 9 + col1,
                            row2 * 9 + col2
                        ]

                        var eliminationCells: [Int] = []
                        for col in 0..<9 {
                            if col != col1 && col != col2 {
                                for row in [row1, row2] {
                                    let index = row * 9 + col
                                    if board[index] == 0 {
                                        let candidates = PuzzleSolver.getCandidates(for: board, at: index)
                                        if candidates.contains(num) {
                                            eliminationCells.append(index)
                                        }
                                    }
                                }
                            }
                        }

                        if !eliminationCells.isEmpty {
                            let cornerNames = cornerCells.map { "R\($0/9 + 1)C\($0%9 + 1)" }
                            let elimCellNames = eliminationCells.map { "R\($0/9 + 1)C\($0%9 + 1)" }.joined(separator: ", ")

                            var steps: [HintStep] = []

                            steps.append(HintStep(
                                title: "Find the X-Wing pattern",
                                explanation: "Look at where \(num) can go in Column \(col1 + 1) and Column \(col2 + 1). In both columns, \(num) can only go in Row \(row1 + 1) or Row \(row2 + 1). This forms a rectangle!",
                                highlightCells: cornerCells,
                                emoji: "✈️"
                            ))

                            steps.append(HintStep(
                                title: "Understand the X-Wing logic",
                                explanation: "The four corners are: \(cornerNames.joined(separator: ", ")). In Column \(col1 + 1), \(num) goes in either Row \(row1 + 1) OR Row \(row2 + 1). The same for Column \(col2 + 1).",
                                highlightCells: cornerCells,
                                emoji: "🔗"
                            ))

                            steps.append(HintStep(
                                title: "Eliminate from the rows",
                                explanation: "Since Rows \(row1 + 1) and \(row2 + 1) will get their \(num) from Column \(col1 + 1) or Column \(col2 + 1), all other cells in these rows can't have \(num). Remove from: \(elimCellNames)",
                                highlightCells: eliminationCells,
                                emoji: "✂️"
                            ))

                            hints.append(TechniqueHint(
                                technique: .xWing,
                                affectedCells: cornerCells,
                                eliminationCells: eliminationCells,
                                candidates: [num],
                                explanation: "X-Wing on \(num): Columns \(col1 + 1) and \(col2 + 1) both have \(num) limited to Rows \(row1 + 1) and \(row2 + 1). Eliminate \(num) from other cells in these rows.",
                                detailedSteps: steps
                            ))
                        }
                    }
                }
            }
        }

        return hints
    }
}
