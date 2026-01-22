import Foundation
import Combine

/// Tracks the current game state including timer, mistakes, and score
class GameState: ObservableObject {
    @Published var puzzle: Puzzle
    @Published var board: Board
    @Published var elapsedTime: TimeInterval = 0
    @Published var mistakes: Int = 0
    @Published var hintsUsed: Int = 0
    @Published var isCompleted: Bool = false
    @Published var isPaused: Bool = false
    @Published var isNotesMode: Bool = false
    @Published var selectedCellIndex: Int? = nil
    @Published var activeHint: TechniqueHint? = nil
    @Published var showingHint: Bool = false

    private var undoStack: [Move] = []
    private var redoStack: [Move] = []
    private var timer: AnyCancellable?
    private var boardCancellable: AnyCancellable?

    let maxMistakes = 3

    init(puzzle: Puzzle) {
        self.puzzle = puzzle
        self.board = puzzle.createBoard()
        startTimer()
        setupBoardObserver()
    }

    private func setupBoardObserver() {
        // Forward board changes to trigger view updates
        boardCancellable = board.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    // MARK: - Timer

    func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, !self.isPaused && !self.isCompleted else { return }
                self.elapsedTime += 1
            }
    }

    func pauseTimer() {
        isPaused = true
    }

    func resumeTimer() {
        isPaused = false
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
    }

    var formattedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Selection

    func selectCell(at index: Int) {
        guard board.cells[index].isEditable || board.cells[index].value != nil else {
            selectedCellIndex = index
            return
        }
        selectedCellIndex = index
    }

    func clearSelection() {
        selectedCellIndex = nil
    }

    // MARK: - Input

    func enterNumber(_ number: Int) {
        guard let index = selectedCellIndex else { return }
        guard board.cells[index].isEditable else { return }

        if isNotesMode {
            enterCandidate(number, at: index)
        } else {
            enterValue(number, at: index)
        }
    }

    private func enterValue(_ value: Int, at index: Int) {
        let oldValue = board.cells[index].value
        let oldCandidates = board.cells[index].candidates

        // Record move for undo
        let move = Move(
            cellIndex: index,
            oldValue: oldValue,
            newValue: value,
            oldCandidates: oldCandidates,
            newCandidates: [],
            wasNotesMode: false
        )
        undoStack.append(move)
        redoStack.removeAll()

        // Set the value
        board.cells[index].setValue(value)

        // Check if correct
        if !puzzle.isCorrect(value: value, at: index) {
            mistakes += 1
            board.cells[index].isError = true
        } else {
            board.cells[index].isError = false
            // Remove this candidate from peers
            removeCandidateFromPeers(value, at: index)
        }

        // Update all errors
        board.updateErrors()

        // Check completion
        checkCompletion()
    }

    private func enterCandidate(_ candidate: Int, at index: Int) {
        guard board.cells[index].value == nil else { return }

        let oldCandidates = board.cells[index].candidates
        board.cells[index].toggleCandidate(candidate)
        let newCandidates = board.cells[index].candidates

        let move = Move.candidateChange(index: index, from: oldCandidates, to: newCandidates)
        undoStack.append(move)
        redoStack.removeAll()
    }

    private func removeCandidateFromPeers(_ value: Int, at index: Int) {
        let peers = board.peerIndices(for: index)
        for peerIndex in peers {
            board.cells[peerIndex].removeCandidate(value)
        }
    }

    // MARK: - Erase

    func eraseSelectedCell() {
        guard let index = selectedCellIndex else { return }
        guard board.cells[index].isEditable else { return }

        let oldValue = board.cells[index].value
        let oldCandidates = board.cells[index].candidates

        if oldValue != nil || !oldCandidates.isEmpty {
            let move = Move(
                cellIndex: index,
                oldValue: oldValue,
                newValue: nil,
                oldCandidates: oldCandidates,
                newCandidates: [],
                wasNotesMode: false
            )
            undoStack.append(move)
            redoStack.removeAll()

            board.cells[index].value = nil
            board.cells[index].candidates.removeAll()
            board.cells[index].isError = false
            board.updateErrors()
        }
    }

    // MARK: - Undo/Redo

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    func undo() {
        guard let move = undoStack.popLast() else { return }

        // Restore old state
        board.cells[move.cellIndex].value = move.oldValue
        board.cells[move.cellIndex].candidates = move.oldCandidates
        board.cells[move.cellIndex].isError = false
        board.updateErrors()

        redoStack.append(move)
    }

    func redo() {
        guard let move = redoStack.popLast() else { return }

        // Apply the move again
        if move.wasNotesMode {
            board.cells[move.cellIndex].candidates = move.newCandidates
        } else {
            board.cells[move.cellIndex].value = move.newValue
            board.cells[move.cellIndex].candidates = move.newCandidates
            if let value = move.newValue, !puzzle.isCorrect(value: value, at: move.cellIndex) {
                board.cells[move.cellIndex].isError = true
            }
        }
        board.updateErrors()

        undoStack.append(move)
    }

    // MARK: - Hints

    func useHint() {
        // Try to find a technique hint first
        if let hint = TechniqueDetector.findBestHint(on: board) {
            activeHint = hint
            showingHint = true
            hintsUsed += 1

            // Select the first affected cell
            if let firstCell = hint.affectedCells.first {
                selectedCellIndex = firstCell
            }
        } else {
            // Fallback: reveal a cell if no technique found
            revealCell()
        }
    }

    func applyHint() {
        guard let hint = activeHint else { return }

        // Apply the hint based on technique type
        if hint.affectedCells.count == 1 && hint.candidates.count == 1 {
            // Single cell placement (naked or hidden single)
            let index = hint.affectedCells[0]
            let value = hint.candidates.first!

            let oldValue = board.cells[index].value
            let oldCandidates = board.cells[index].candidates

            let move = Move(
                cellIndex: index,
                oldValue: oldValue,
                newValue: value,
                oldCandidates: oldCandidates,
                newCandidates: [],
                wasNotesMode: false
            )
            undoStack.append(move)
            redoStack.removeAll()

            board.cells[index].setValue(value)
            board.cells[index].isError = false
            removeCandidateFromPeers(value, at: index)
        }
        // Note: For elimination techniques (naked pairs, etc.), we would
        // remove candidates from elimination cells. For now, we just place values.

        dismissHint()
        board.updateErrors()
        checkCompletion()
    }

    func dismissHint() {
        activeHint = nil
        showingHint = false
    }

    private func revealCell() {
        // Fallback hint: reveal a cell
        guard let index = findBestHintCell() else { return }

        let correctValue = puzzle.solution[index]
        let oldValue = board.cells[index].value
        let oldCandidates = board.cells[index].candidates

        let move = Move(
            cellIndex: index,
            oldValue: oldValue,
            newValue: correctValue,
            oldCandidates: oldCandidates,
            newCandidates: [],
            wasNotesMode: false
        )
        undoStack.append(move)
        redoStack.removeAll()

        board.cells[index].value = correctValue
        board.cells[index].candidates.removeAll()
        board.cells[index].isError = false
        hintsUsed += 1

        removeCandidateFromPeers(correctValue, at: index)
        board.updateErrors()
        checkCompletion()

        selectedCellIndex = index
    }

    private func findBestHintCell() -> Int? {
        // Prefer selected cell if empty
        if let selected = selectedCellIndex, board.cells[selected].value == nil {
            return selected
        }
        // Otherwise find first empty cell
        return board.cells.first { $0.value == nil }?.id
    }

    // MARK: - Completion

    private func checkCompletion() {
        if board.isSolved {
            isCompleted = true
            stopTimer()
        }
    }

    var isGameOver: Bool {
        mistakes >= maxMistakes
    }

    // MARK: - Solvability Check

    /// Check if the current board state can still be solved
    /// Returns: .solvable, .unsolvable, or .hasErrors
    func checkSolvability() -> SolvabilityResult {
        // First check if there are any errors (conflicts)
        for i in 0..<81 {
            if board.cells[i].value != nil && board.hasConflict(at: i) {
                return .hasErrors
            }
        }

        // Build current board state as array
        var currentState = [Int](repeating: 0, count: 81)
        for i in 0..<81 {
            currentState[i] = board.cells[i].value ?? 0
        }

        // Check if it has at least one solution
        if PuzzleSolver.solve(currentState) != nil {
            return .solvable
        } else {
            return .unsolvable
        }
    }

    // MARK: - Score

    var score: Int {
        guard isCompleted else { return 0 }

        let baseScore: Int
        switch puzzle.difficulty {
        case .easy: baseScore = 1000
        case .medium: baseScore = 2000
        case .hard: baseScore = 3000
        }

        let timeBonus = max(0, 1000 - Int(elapsedTime / 10))
        let mistakePenalty = mistakes * 100
        let hintPenalty = hintsUsed * 50

        return max(0, baseScore + timeBonus - mistakePenalty - hintPenalty)
    }

    // MARK: - Reset

    func reset() {
        board = puzzle.createBoard()
        setupBoardObserver()
        elapsedTime = 0
        mistakes = 0
        hintsUsed = 0
        isCompleted = false
        isPaused = false
        selectedCellIndex = nil
        undoStack.removeAll()
        redoStack.removeAll()
        startTimer()
    }
}
