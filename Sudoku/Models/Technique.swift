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
