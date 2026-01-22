import Foundation

/// Represents a single cell in the Sudoku grid
struct Cell: Identifiable, Equatable, Hashable {
    let id: Int // 0-80
    var value: Int? // 1-9 or nil
    var candidates: Set<Int> // pencil marks (1-9)
    var isGiven: Bool // starting clue (not editable)
    var isError: Bool // wrong value

    var row: Int { id / 9 }
    var col: Int { id % 9 }
    var box: Int { (row / 3) * 3 + (col / 3) }

    init(id: Int, value: Int? = nil, candidates: Set<Int> = [], isGiven: Bool = false, isError: Bool = false) {
        self.id = id
        self.value = value
        self.candidates = candidates
        self.isGiven = isGiven
        self.isError = isError
    }

    var isEmpty: Bool {
        value == nil
    }

    var isEditable: Bool {
        !isGiven
    }

    mutating func setValue(_ newValue: Int?) {
        guard isEditable else { return }
        value = newValue
        if newValue != nil {
            candidates.removeAll()
        }
    }

    mutating func toggleCandidate(_ candidate: Int) {
        guard isEditable && value == nil else { return }
        if candidates.contains(candidate) {
            candidates.remove(candidate)
        } else {
            candidates.insert(candidate)
        }
    }

    mutating func removeCandidate(_ candidate: Int) {
        candidates.remove(candidate)
    }

    mutating func clearCandidates() {
        candidates.removeAll()
    }
}
