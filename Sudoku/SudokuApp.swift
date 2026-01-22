import SwiftUI

@main
struct SudokuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/// Root content view managing navigation between menu and game
struct ContentView: View {
    @State private var selectedDifficulty: Difficulty?
    @State private var isShowingGame = false
    @State private var generatedPuzzle: Puzzle?

    var body: some View {
        NavigationStack {
            MainMenuView(
                selectedDifficulty: $selectedDifficulty,
                isShowingGame: $isShowingGame,
                generatedPuzzle: $generatedPuzzle
            )
            .navigationDestination(isPresented: $isShowingGame) {
                if let puzzle = generatedPuzzle {
                    GameView(puzzle: puzzle)
                } else if let difficulty = selectedDifficulty {
                    GameView(difficulty: difficulty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
