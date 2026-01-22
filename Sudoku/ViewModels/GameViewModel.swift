import Foundation
import Combine
import SwiftUI

/// Main view model for the Sudoku game
class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var showingPauseMenu: Bool = false
    @Published var showingCompletionAlert: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init(puzzle: Puzzle) {
        self.gameState = GameState(puzzle: puzzle)
        setupObservers()
    }

    convenience init(difficulty: Difficulty, generateNew: Bool = false) {
        let puzzle = PuzzleStore.shared.getPuzzle(difficulty: difficulty, generateNew: generateNew)
        self.init(puzzle: puzzle)
    }

    private func setupObservers() {
        // Forward all gameState changes to trigger view updates
        gameState.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        // Watch for game completion
        gameState.$isCompleted
            .sink { [weak self] completed in
                if completed {
                    self?.showingCompletionAlert = true
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Cell Selection

    var selectedCellIndex: Int? {
        get { gameState.selectedCellIndex }
        set { gameState.selectedCellIndex = newValue }
    }

    func selectCell(at index: Int) {
        gameState.selectCell(at: index)
    }

    // MARK: - Highlighting

    func highlightType(for index: Int) -> CellHighlightType {
        // Hint highlighting takes priority when showing hint
        if showingHint {
            if isHintAffectedCell(index) {
                return .hintAffected
            }
            if isHintEliminationCell(index) {
                return .hintElimination
            }
        }

        guard let selectedIndex = selectedCellIndex else {
            return .none
        }

        if index == selectedIndex {
            return .selected
        }

        let selectedCell = gameState.board.cells[selectedIndex]
        let currentCell = gameState.board.cells[index]

        // Same value highlighting
        if let selectedValue = selectedCell.value,
           let currentValue = currentCell.value,
           selectedValue == currentValue {
            return .sameNumber
        }

        // Row/Column/Box highlighting
        if currentCell.row == selectedCell.row ||
           currentCell.col == selectedCell.col ||
           currentCell.box == selectedCell.box {
            return .rowColBox
        }

        return .none
    }

    // MARK: - Input

    func enterNumber(_ number: Int) {
        gameState.enterNumber(number)
    }

    func eraseSelectedCell() {
        gameState.eraseSelectedCell()
    }

    // MARK: - Notes Mode

    var isNotesMode: Bool {
        get { gameState.isNotesMode }
        set { gameState.isNotesMode = newValue }
    }

    func toggleNotesMode() {
        gameState.isNotesMode.toggle()
    }

    // MARK: - Undo/Redo

    var canUndo: Bool { gameState.canUndo }
    var canRedo: Bool { gameState.canRedo }

    func undo() {
        gameState.undo()
    }

    func redo() {
        gameState.redo()
    }

    // MARK: - Hints

    var showingHint: Bool {
        get { gameState.showingHint }
        set { gameState.showingHint = newValue }
    }

    var activeHint: TechniqueHint? {
        gameState.activeHint
    }

    func useHint() {
        gameState.useHint()
    }

    /// Use a hint for a specific technique (for Learn Mode)
    func useHintForTechnique(_ technique: TechniqueType) {
        gameState.useHintForTechnique(technique)
    }

    func applyHint() {
        gameState.applyHint()
    }

    func dismissHint() {
        gameState.dismissHint()
    }

    // Check if a cell is part of the current hint
    func isHintAffectedCell(_ index: Int) -> Bool {
        activeHint?.affectedCells.contains(index) ?? false
    }

    func isHintEliminationCell(_ index: Int) -> Bool {
        activeHint?.eliminationCells.contains(index) ?? false
    }

    // MARK: - Learn Techniques in Context

    @Published var showingTechniqueExplorer: Bool = false
    @Published var detectedTechniques: [TechniqueHint] = []
    @Published var currentTechniqueIndex: Int = 0

    var currentTechnique: TechniqueHint? {
        guard !detectedTechniques.isEmpty,
              currentTechniqueIndex < detectedTechniques.count else { return nil }
        return detectedTechniques[currentTechniqueIndex]
    }

    func openTechniqueExplorer() {
        // Find all techniques on the current board
        detectedTechniques = TechniqueDetector.findTechniques(on: board)
        currentTechniqueIndex = 0
        showingTechniqueExplorer = true

        // Highlight the first technique if found
        if let technique = currentTechnique {
            gameState.activeHint = technique
            gameState.showingHint = true
        }
    }

    func closeTechniqueExplorer() {
        showingTechniqueExplorer = false
        gameState.activeHint = nil
        gameState.showingHint = false
    }

    func nextTechnique() {
        guard currentTechniqueIndex < detectedTechniques.count - 1 else { return }
        currentTechniqueIndex += 1
        if let technique = currentTechnique {
            gameState.activeHint = technique
            if let firstCell = technique.affectedCells.first {
                selectedCellIndex = firstCell
            }
        }
    }

    func previousTechnique() {
        guard currentTechniqueIndex > 0 else { return }
        currentTechniqueIndex -= 1
        if let technique = currentTechnique {
            gameState.activeHint = technique
            if let firstCell = technique.affectedCells.first {
                selectedCellIndex = firstCell
            }
        }
    }

    func applyCurrentTechnique() {
        guard let technique = currentTechnique else { return }
        gameState.activeHint = technique
        gameState.applyHint()

        // Refresh techniques after applying
        detectedTechniques = TechniqueDetector.findTechniques(on: board)
        currentTechniqueIndex = min(currentTechniqueIndex, max(0, detectedTechniques.count - 1))

        if let newTechnique = currentTechnique {
            gameState.activeHint = newTechnique
            if let firstCell = newTechnique.affectedCells.first {
                selectedCellIndex = firstCell
            }
        } else {
            closeTechniqueExplorer()
        }
    }

    // MARK: - Pause

    func pause() {
        gameState.pauseTimer()
        showingPauseMenu = true
    }

    func resume() {
        showingPauseMenu = false
        gameState.resumeTimer()
    }

    // MARK: - Game Control

    func reset() {
        gameState.reset()
        showingCompletionAlert = false
    }

    func newGame(difficulty: Difficulty, generateNew: Bool = false) {
        let puzzle = PuzzleStore.shared.getPuzzle(difficulty: difficulty, generateNew: generateNew)
        cancellables.removeAll()
        gameState = GameState(puzzle: puzzle)
        setupObservers()
        showingCompletionAlert = false
    }

    /// Generate a brand new puzzle (algorithmic generation)
    func generateNewPuzzle(difficulty: Difficulty) {
        let puzzle = PuzzleGenerator.generate(difficulty: difficulty)
        cancellables.removeAll()
        gameState = GameState(puzzle: puzzle)
        setupObservers()
        showingCompletionAlert = false
    }

    // MARK: - Solvability

    @Published var solvabilityResult: SolvabilityResult? = nil
    @Published var showingSolvabilityResult: Bool = false

    func checkSolvability() {
        solvabilityResult = gameState.checkSolvability()
        showingSolvabilityResult = true
    }

    func dismissSolvabilityResult() {
        showingSolvabilityResult = false
        solvabilityResult = nil
    }

    // MARK: - Game Info

    var difficulty: Difficulty {
        gameState.puzzle.difficulty
    }

    var formattedTime: String {
        gameState.formattedTime
    }

    var mistakes: Int {
        gameState.mistakes
    }

    var maxMistakes: Int {
        gameState.maxMistakes
    }

    var score: Int {
        gameState.score
    }

    var board: Board {
        gameState.board
    }

    var isGameOver: Bool {
        gameState.isGameOver
    }

    var isCompleted: Bool {
        gameState.isCompleted
    }

    // MARK: - Number Count

    func countOfNumber(_ number: Int) -> Int {
        gameState.board.cells.filter { $0.value == number }.count
    }

    func isNumberComplete(_ number: Int) -> Bool {
        countOfNumber(number) >= 9
    }
}

/// Types of cell highlighting
enum CellHighlightType {
    case none
    case selected
    case rowColBox
    case sameNumber
    case error
    case hintAffected
    case hintElimination
}
