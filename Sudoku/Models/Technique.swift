import Foundation

/// Categories of Sudoku solving techniques
enum TechniqueCategory: String, CaseIterable {
    case basic = "Basic"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

/// All supported Sudoku solving techniques
enum TechniqueType: String, CaseIterable, Identifiable {
    case nakedSingle = "Naked Single"
    case hiddenSingle = "Hidden Single"
    case nakedPair = "Naked Pair"
    case nakedTriple = "Naked Triple"
    case hiddenPair = "Hidden Pair"
    case hiddenTriple = "Hidden Triple"
    case pointingPair = "Pointing Pair"
    case boxLineReduction = "Box/Line Reduction"
    case xWing = "X-Wing"
    case swordfish = "Swordfish"

    var id: String { rawValue }

    var category: TechniqueCategory {
        switch self {
        case .nakedSingle, .hiddenSingle:
            return .basic
        case .nakedPair, .nakedTriple, .hiddenPair, .hiddenTriple, .pointingPair, .boxLineReduction:
            return .intermediate
        case .xWing, .swordfish:
            return .advanced
        }
    }

    var description: String {
        switch self {
        case .nakedSingle:
            return "When a cell has only one possible candidate, that candidate must be the answer."
        case .hiddenSingle:
            return "When a number can only go in one cell within a row, column, or box, it must go there."
        case .nakedPair:
            return "When two cells in a unit contain the same two candidates and only those, those candidates can be eliminated from other cells in that unit."
        case .nakedTriple:
            return "Similar to Naked Pair but with three cells sharing three candidates."
        case .hiddenPair:
            return "When two candidates appear only in two cells within a unit, other candidates can be eliminated from those cells."
        case .hiddenTriple:
            return "Similar to Hidden Pair but with three candidates in three cells."
        case .pointingPair:
            return "When a candidate in a box is restricted to a single row or column, that candidate can be eliminated from that row/column outside the box."
        case .boxLineReduction:
            return "When a candidate in a row or column is restricted to a single box, that candidate can be eliminated from other cells in that box."
        case .xWing:
            return "When a candidate appears in exactly two cells in each of two rows, and those cells are in the same columns, the candidate can be eliminated from other cells in those columns."
        case .swordfish:
            return "An extension of X-Wing using three rows and three columns."
        }
    }

    var difficulty: Difficulty {
        switch category {
        case .basic: return .easy
        case .intermediate: return .medium
        case .advanced: return .hard
        }
    }

    var shortDescription: String {
        switch self {
        case .nakedSingle:
            return "A cell with only one possible number"
        case .hiddenSingle:
            return "A number that can only go in one cell"
        case .nakedPair:
            return "Two cells sharing the same two candidates"
        case .nakedTriple:
            return "Three cells sharing three candidates"
        case .hiddenPair:
            return "Two numbers limited to the same two cells"
        case .hiddenTriple:
            return "Three numbers limited to three cells"
        case .pointingPair:
            return "Candidates in a box aligned to one row/column"
        case .boxLineReduction:
            return "Candidates in a row/column confined to one box"
        case .xWing:
            return "Rectangle pattern that eliminates candidates"
        case .swordfish:
            return "Three-row/column fish pattern"
        }
    }

    var howToSpot: String {
        switch self {
        case .nakedSingle:
            return "Look for cells where you've eliminated all but one candidate. These often appear after you've filled in several numbers. The cell will have only one pencil mark left."
        case .hiddenSingle:
            return "Pick a number (1-9) and ask: \"Where can this number go in this row/column/box?\" If there's only one possible cell, you found a hidden single!"
        case .nakedPair:
            return "Look for two cells in the same row, column, or box that have exactly the same two candidates. Both cells show the same two numbers and nothing else."
        case .nakedTriple:
            return "Similar to naked pairs, but with three cells. The cells don't each need all three candidates — they just can't have any candidates outside the set of three."
        case .hiddenPair:
            return "Look for two numbers that only appear as candidates in the same two cells within a unit. They're \"hidden\" because the cells may have other candidates too."
        case .hiddenTriple:
            return "Three numbers that only appear in three cells within a unit. Harder to spot than hidden pairs!"
        case .pointingPair:
            return "In a 3×3 box, find a number that can only go in cells that are all in the same row or column. The candidates will \"point\" in one direction."
        case .boxLineReduction:
            return "In a row or column, find a number whose candidates are all within a single 3×3 box. The opposite of pointing pairs!"
        case .xWing:
            return "Find a number that appears in exactly 2 cells in two different rows, where those cells line up in the same two columns (forming a rectangle)."
        case .swordfish:
            return "Like X-Wing but with three rows and three columns instead of two."
        }
    }

    var steps: [String] {
        switch self {
        case .nakedSingle:
            return [
                "Find an empty cell",
                "Check which numbers are already in its row, column, and box",
                "If only one number is missing from all three, that's your answer",
                "Fill in the number!"
            ]
        case .hiddenSingle:
            return [
                "Pick a unit (row, column, or box)",
                "Choose a number that's missing from that unit",
                "Check each empty cell: can this number go here?",
                "If only one cell can hold the number, place it there"
            ]
        case .nakedPair:
            return [
                "Find two cells in the same unit with identical candidates",
                "Both cells must have exactly two candidates, and they must be the same",
                "These two numbers must go in these two cells",
                "Remove these candidates from all other cells in the unit"
            ]
        case .nakedTriple:
            return [
                "Find three cells in a unit that collectively contain only three candidates",
                "Each cell can have 2 or 3 of these candidates",
                "These three numbers must fill these three cells",
                "Remove these candidates from other cells in the unit"
            ]
        case .hiddenPair:
            return [
                "In a unit, find two numbers that appear as candidates in only two cells",
                "These two numbers must be in these two cells",
                "Remove all OTHER candidates from these two cells",
                "Continue solving with the simplified candidates"
            ]
        case .hiddenTriple:
            return [
                "Find three numbers that only appear in three cells within a unit",
                "These numbers must fill these cells",
                "Remove other candidates from these three cells"
            ]
        case .pointingPair:
            return [
                "Look at a 3×3 box and pick a candidate number",
                "If that number only appears in cells along one row or column...",
                "That row/column's instance of the number MUST come from this box",
                "Remove the candidate from that row/column OUTSIDE the box"
            ]
        case .boxLineReduction:
            return [
                "Look at a row or column and pick a candidate number",
                "If that number only appears within one 3×3 box...",
                "The box's instance of the number MUST come from this line",
                "Remove the candidate from other cells in the box"
            ]
        case .xWing:
            return [
                "Find a number that appears in exactly 2 cells in a row",
                "Find another row where the same number appears in exactly 2 cells in the same columns",
                "This forms a rectangle — the number will occupy opposite corners",
                "Remove this candidate from other cells in those two columns"
            ]
        case .swordfish:
            return [
                "Find a number that appears in 2-3 cells across three rows",
                "These cells must align to exactly three columns",
                "The number will be placed once in each row and column",
                "Remove the candidate from other cells in those columns"
            ]
        }
    }

    var proTip: String {
        switch self {
        case .nakedSingle:
            return "Keep your pencil marks updated! Naked singles become obvious when you maintain accurate candidates."
        case .hiddenSingle:
            return "Systematically check each number 1-9 in each box. This catches hidden singles that are easy to miss."
        case .nakedPair:
            return "After finding a naked pair, immediately check if the eliminations create new naked singles!"
        case .nakedTriple:
            return "Remember: in a naked triple, each cell doesn't need all three numbers — just subsets of them."
        case .hiddenPair:
            return "Hidden pairs are easier to find in boxes than in rows/columns. Start there!"
        case .hiddenTriple:
            return "These are rare. Focus on mastering easier techniques first."
        case .pointingPair:
            return "Always check both directions when you spot candidates aligned in a box."
        case .boxLineReduction:
            return "This technique is the reverse of pointing pairs. If you find one, look for the other!"
        case .xWing:
            return "X-Wings are named because the eliminations form an X pattern when drawn on the grid."
        case .swordfish:
            return "Swordfish is an advanced pattern. Master X-Wing first before attempting this."
        }
    }
}

/// A hint about applying a technique
struct TechniqueHint: Identifiable {
    let id = UUID()
    let technique: TechniqueType
    let affectedCells: [Int] // Cells involved in the pattern
    let eliminationCells: [Int] // Cells where candidates can be eliminated
    let candidates: Set<Int> // The candidate numbers involved
    let explanation: String
    let detailedSteps: [HintStep] // Step-by-step walkthrough

    var title: String {
        technique.rawValue
    }

    init(technique: TechniqueType, affectedCells: [Int], eliminationCells: [Int], candidates: Set<Int>, explanation: String, detailedSteps: [HintStep] = []) {
        self.technique = technique
        self.affectedCells = affectedCells
        self.eliminationCells = eliminationCells
        self.candidates = candidates
        self.explanation = explanation
        self.detailedSteps = detailedSteps
    }
}

/// A single step in a hint explanation
struct HintStep: Identifiable {
    let id = UUID()
    let title: String
    let explanation: String
    let highlightCells: [Int]
    let emoji: String

    init(title: String, explanation: String, highlightCells: [Int] = [], emoji: String = "") {
        self.title = title
        self.explanation = explanation
        self.highlightCells = highlightCells
        self.emoji = emoji
    }
}

/// A lesson for teaching a technique
struct TechniqueLesson: Identifiable {
    let id = UUID()
    let technique: TechniqueType
    let steps: [LessonStep]
    let practiceBoard: [Int] // A puzzle that requires this technique

    struct LessonStep: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let highlightCells: [Int]
        let highlightCandidates: [(cell: Int, candidate: Int)]
    }
}

/// Pre-defined lessons for each technique
struct TechniqueLessons {
    static let nakedSingle = TechniqueLesson(
        technique: .nakedSingle,
        steps: [
            .init(
                title: "Find the Cell",
                description: "Look for cells that have only one possible candidate remaining.",
                highlightCells: [],
                highlightCandidates: []
            ),
            .init(
                title: "Check Constraints",
                description: "A naked single occurs when all other numbers 1-9 are already present in the cell's row, column, or box.",
                highlightCells: [],
                highlightCandidates: []
            ),
            .init(
                title: "Place the Number",
                description: "The only remaining candidate must be the answer for that cell.",
                highlightCells: [],
                highlightCandidates: []
            )
        ],
        practiceBoard: []
    )

    static let hiddenSingle = TechniqueLesson(
        technique: .hiddenSingle,
        steps: [
            .init(
                title: "Examine a Unit",
                description: "Look at a row, column, or box and consider where each missing number can go.",
                highlightCells: [],
                highlightCandidates: []
            ),
            .init(
                title: "Find the Only Spot",
                description: "If a number can only go in one cell within that unit, you've found a hidden single.",
                highlightCells: [],
                highlightCandidates: []
            ),
            .init(
                title: "Place the Number",
                description: "Even if the cell has other candidates, this number must go here because there's no other option in the unit.",
                highlightCells: [],
                highlightCandidates: []
            )
        ],
        practiceBoard: []
    )

    static let nakedPair = TechniqueLesson(
        technique: .nakedPair,
        steps: [
            .init(
                title: "Find Two Cells",
                description: "Look for two cells in the same row, column, or box that contain exactly the same two candidates.",
                highlightCells: [],
                highlightCandidates: []
            ),
            .init(
                title: "Understand the Logic",
                description: "These two numbers must go in these two cells, though we don't know which goes where yet.",
                highlightCells: [],
                highlightCandidates: []
            ),
            .init(
                title: "Eliminate Candidates",
                description: "Remove these two candidates from all other cells in the same unit.",
                highlightCells: [],
                highlightCandidates: []
            )
        ],
        practiceBoard: []
    )

    static var allLessons: [TechniqueLesson] {
        [nakedSingle, hiddenSingle, nakedPair]
    }
}
