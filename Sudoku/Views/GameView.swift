import SwiftUI

/// Main game screen
struct GameView: View {
    @StateObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingNewGameAlert = false

    init(difficulty: Difficulty) {
        _viewModel = StateObject(wrappedValue: GameViewModel(difficulty: difficulty))
    }

    init(puzzle: Puzzle) {
        _viewModel = StateObject(wrappedValue: GameViewModel(puzzle: puzzle))
    }

    var body: some View {
        ZStack {
            // Background
            Constants.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Header with back button and stats
                HStack(spacing: 16) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Constants.Colors.toolbarButton)
                    }

                    Spacer()

                    StatsBarView(viewModel: viewModel) {
                        viewModel.pause()
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Board
                BoardView(viewModel: viewModel)
                    .padding(.horizontal)

                Spacer()

                // Toolbar
                ToolbarView(viewModel: viewModel)
                    .padding(.horizontal)

                // Number pad
                NumberPadView(viewModel: viewModel)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }

            // Hint overlay (only when not in technique explorer)
            if viewModel.showingHint && !viewModel.showingTechniqueExplorer,
               let hint = viewModel.activeHint {
                HintOverlayView(
                    hint: hint,
                    onApply: { viewModel.applyHint() },
                    onDismiss: { viewModel.dismissHint() }
                )
                .animation(Constants.Animation.standard, value: viewModel.showingHint)
            }

            // Technique explorer overlay
            if viewModel.showingTechniqueExplorer {
                TechniqueExplorerView(viewModel: viewModel)
                    .animation(Constants.Animation.standard, value: viewModel.showingTechniqueExplorer)
            }

            // Pause overlay
            if viewModel.showingPauseMenu {
                PauseMenuOverlay(
                    onResume: { viewModel.resume() },
                    onRestart: {
                        viewModel.reset()
                        viewModel.showingPauseMenu = false
                    },
                    onNewGame: { showingNewGameAlert = true },
                    onQuit: { dismiss() }
                )
            }
        }
        .navigationBarHidden(true)
        .alert("Game Complete!", isPresented: $viewModel.showingCompletionAlert) {
            Button("New Game") {
                showingNewGameAlert = true
            }
            Button("Main Menu") {
                dismiss()
            }
        } message: {
            Text("Congratulations! You solved the puzzle.\nScore: \(viewModel.score)\nTime: \(viewModel.formattedTime)")
        }
        .confirmationDialog("Select Difficulty", isPresented: $showingNewGameAlert) {
            ForEach(Difficulty.allCases) { difficulty in
                Button(difficulty.rawValue) {
                    viewModel.newGame(difficulty: difficulty)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert(solvabilityTitle, isPresented: $viewModel.showingSolvabilityResult) {
            Button("OK") {
                viewModel.dismissSolvabilityResult()
            }
        } message: {
            Text(viewModel.solvabilityResult?.message ?? "")
        }
    }

    private var solvabilityTitle: String {
        guard let result = viewModel.solvabilityResult else { return "Check" }
        switch result {
        case .solvable:
            return "Looking Good!"
        case .unsolvable:
            return "Uh Oh..."
        case .hasErrors:
            return "Conflicts Found"
        }
    }
}

/// Overlay shown when game is paused
struct PauseMenuOverlay: View {
    let onResume: () -> Void
    let onRestart: () -> Void
    let onNewGame: () -> Void
    let onQuit: () -> Void

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onResume()
                }

            // Menu card
            VStack(spacing: 20) {
                Text("Paused")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Constants.Colors.primaryButton)

                VStack(spacing: 12) {
                    PauseMenuButton(title: "Resume", icon: "play.fill", action: onResume)
                    PauseMenuButton(title: "Restart", icon: "arrow.counterclockwise", action: onRestart)
                    PauseMenuButton(title: "New Game", icon: "plus.circle", action: onNewGame)
                    PauseMenuButton(title: "Quit", icon: "house", action: onQuit)
                }
            }
            .padding(32)
            .background(Constants.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: Constants.Sizing.cardCornerRadius))
            .shadow(radius: 20)
        }
    }
}

struct PauseMenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                Text(title)
                Spacer()
            }
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(Constants.Colors.toolbarButton)
            .padding()
            .frame(width: 200)
            .background(Constants.Colors.highlightRowColBox)
            .clipShape(RoundedRectangle(cornerRadius: Constants.Sizing.buttonCornerRadius))
        }
    }
}

#Preview {
    GameView(difficulty: .easy)
}
