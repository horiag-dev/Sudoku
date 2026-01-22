import Foundation

/// Represents the 9x9 Sudoku grid
class Board: ObservableObject {
    @Published var cells: [Cell]

    init(cells: [Cell]? = nil) {
        if let cells = cells {
            self.cells = cells
        } else {
            self.cells = (0..<81).map { Cell(id: $0) }
        }
    }

    // MARK: - Cell Access

    func cell(at index: Int) -> Cell {
        guard index >= 0 && index < 81 else {
            fatalError("Cell index out of range: \(index)")
        }
        return cells[index]
    }

    func cell(row: Int, col: Int) -> Cell {
        let index = row * 9 + col
        return cell(at: index)
    }

    subscript(row: Int, col: Int) -> Cell {
        get { cell(row: row, col: col) }
        set { cells[row * 9 + col] = newValue }
    }

    subscript(index: Int) -> Cell {
        get { cells[index] }
        set { cells[index] = newValue }
    }

    // MARK: - Unit Access (Row, Column, Box)

    func cellsInRow(_ row: Int) -> [Cell] {
        (0..<9).map { cell(row: row, col: $0) }
    }

    func cellsInColumn(_ col: Int) -> [Cell] {
        (0..<9).map { cell(row: $0, col: col) }
    }

    func cellsInBox(_ box: Int) -> [Cell] {
        let startRow = (box / 3) * 3
        let startCol = (box % 3) * 3
        var result: [Cell] = []
        for r in startRow..<startRow + 3 {
            for c in startCol..<startCol + 3 {
                result.append(cell(row: r, col: c))
            }
        }
        return result
    }

    func indicesInRow(_ row: Int) -> [Int] {
        (0..<9).map { row * 9 + $0 }
    }

    func indicesInColumn(_ col: Int) -> [Int] {
        (0..<9).map { $0 * 9 + col }
    }

    func indicesInBox(_ box: Int) -> [Int] {
        let startRow = (box / 3) * 3
        let startCol = (box % 3) * 3
        var result: [Int] = []
        for r in startRow..<startRow + 3 {
            for c in startCol..<startCol + 3 {
                result.append(r * 9 + c)
            }
        }
        return result
    }

    // MARK: - Peers (cells that see a given cell)

    func peerIndices(for index: Int) -> Set<Int> {
        let cell = cells[index]
        var peers = Set<Int>()
        peers.formUnion(indicesInRow(cell.row))
        peers.formUnion(indicesInColumn(cell.col))
        peers.formUnion(indicesInBox(cell.box))
        peers.remove(index)
        return peers
    }

    // MARK: - Validation

    func isValidPlacement(_ value: Int, at index: Int) -> Bool {
        let cell = cells[index]
        let peers = peerIndices(for: index)
        for peerIndex in peers {
            if cells[peerIndex].value == value {
                return false
            }
        }
        return true
    }

    func hasConflict(at index: Int) -> Bool {
        guard let value = cells[index].value else { return false }
        let peers = peerIndices(for: index)
        for peerIndex in peers {
            if cells[peerIndex].value == value {
                return true
            }
        }
        return false
    }

    func updateErrors() {
        for i in 0..<81 {
            cells[i].isError = hasConflict(at: i)
        }
    }

    // MARK: - Board State

    var isSolved: Bool {
        for cell in cells {
            if cell.value == nil || cell.isError {
                return false
            }
        }
        return true
    }

    var isComplete: Bool {
        cells.allSatisfy { $0.value != nil }
    }

    var emptyCellCount: Int {
        cells.filter { $0.value == nil }.count
    }

    var filledCellCount: Int {
        81 - emptyCellCount
    }

    // MARK: - Copy

    func copy() -> Board {
        let newCells = cells.map { cell in
            Cell(id: cell.id, value: cell.value, candidates: cell.candidates, isGiven: cell.isGiven, isError: cell.isError)
        }
        return Board(cells: newCells)
    }

    // MARK: - Serialization

    func toArray() -> [Int] {
        cells.map { $0.value ?? 0 }
    }

    static func fromArray(_ array: [Int], givens: Set<Int> = []) -> Board {
        let cells = array.enumerated().map { index, value in
            Cell(id: index, value: value == 0 ? nil : value, isGiven: givens.contains(index) || value != 0)
        }
        return Board(cells: cells)
    }
}
