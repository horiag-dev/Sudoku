import Foundation

/// Result of checking if the current board state is solvable
enum SolvabilityResult {
    case solvable
    case unsolvable
    case hasErrors

    var message: String {
        switch self {
        case .solvable:
            return "This puzzle can be solved from here."
        case .unsolvable:
            return "This puzzle cannot be solved from the current state. You may have made a wrong move."
        case .hasErrors:
            return "There are conflicts on the board. Fix the red numbers first."
        }
    }

    var isOk: Bool {
        self == .solvable
    }
}

/// Difficulty levels for Sudoku puzzles
enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

    var id: String { rawValue }

    var givenCellRange: ClosedRange<Int> {
        switch self {
        case .easy: return 36...40
        case .medium: return 30...35
        case .hard: return 24...29
        }
    }

    var description: String {
        switch self {
        case .easy: return "Perfect for beginners. Only basic techniques needed."
        case .medium: return "Requires some advanced thinking."
        case .hard: return "Challenging puzzles for experienced players."
        }
    }
}

/// A Sudoku puzzle with its solution
struct Puzzle: Identifiable {
    let id: UUID
    let difficulty: Difficulty
    let initialBoard: [Int] // 81 elements, 0 = empty
    let solution: [Int] // 81 elements, fully solved

    init(id: UUID = UUID(), difficulty: Difficulty, initialBoard: [Int], solution: [Int]) {
        self.id = id
        self.difficulty = difficulty
        self.initialBoard = initialBoard
        self.solution = solution
    }

    var givenIndices: Set<Int> {
        Set(initialBoard.indices.filter { initialBoard[$0] != 0 })
    }

    var givenCount: Int {
        initialBoard.filter { $0 != 0 }.count
    }

    func createBoard() -> Board {
        let cells = initialBoard.enumerated().map { index, value in
            Cell(
                id: index,
                value: value == 0 ? nil : value,
                isGiven: value != 0
            )
        }
        return Board(cells: cells)
    }

    func isCorrect(value: Int, at index: Int) -> Bool {
        solution[index] == value
    }
}

/// Represents a move in the game for undo/redo
struct Move: Equatable {
    let cellIndex: Int
    let oldValue: Int?
    let newValue: Int?
    let oldCandidates: Set<Int>
    let newCandidates: Set<Int>
    let wasNotesMode: Bool

    static func valueChange(index: Int, from oldValue: Int?, to newValue: Int?) -> Move {
        Move(cellIndex: index, oldValue: oldValue, newValue: newValue, oldCandidates: [], newCandidates: [], wasNotesMode: false)
    }

    static func candidateChange(index: Int, from oldCandidates: Set<Int>, to newCandidates: Set<Int>) -> Move {
        Move(cellIndex: index, oldValue: nil, newValue: nil, oldCandidates: oldCandidates, newCandidates: newCandidates, wasNotesMode: true)
    }
}
