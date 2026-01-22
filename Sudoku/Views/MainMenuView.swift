import SwiftUI

/// Main menu screen with difficulty selection
struct MainMenuView: View {
    @Binding var selectedDifficulty: Difficulty?
    @Binding var isShowingGame: Bool
    @Binding var generatedPuzzle: Puzzle?
    @State private var showingTechniqueLibrary = false
    @State private var showingLearnMode = false
    @State private var isGenerating = false
    @State private var showingGenerateOptions = false

    var body: some View {
        ZStack {
            // Background
            Constants.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    Text("Sudoku")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(Constants.Colors.primaryButton)

                    Text("Train your brain")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Constants.Colors.candidates)
                }

                Spacer()

                // Play from pre-made puzzles
                VStack(spacing: 16) {
                    Text("Play")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Constants.Colors.toolbarButton)

                    ForEach(Difficulty.allCases) { difficulty in
                        DifficultyButton(difficulty: difficulty) {
                            selectedDifficulty = difficulty
                            generatedPuzzle = nil
                            isShowingGame = true
                        }
                    }
                }

                // Generate new puzzle section
                VStack(spacing: 12) {
                    Button(action: { showingGenerateOptions = true }) {
                        HStack(spacing: 8) {
                            if isGenerating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "wand.and.stars")
                            }
                            Text(isGenerating ? "Generating..." : "Generate New Puzzle")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 340)
                        .background(Constants.Colors.primaryButton)
                        .clipShape(RoundedRectangle(cornerRadius: Constants.Sizing.buttonCornerRadius))
                    }
                    .disabled(isGenerating)

                    Text("Create a brand new random puzzle")
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.candidates)
                }

                Spacer()

                // Learn section
                VStack(spacing: 12) {
                    // Learn Mode - Practice techniques
                    Button(action: { showingLearnMode = true }) {
                        HStack {
                            Image(systemName: "graduationcap.fill")
                            Text("Learn Mode")
                            Spacer()
                            Text("Practice techniques")
                                .font(.system(size: 12))
                                .foregroundColor(Constants.Colors.candidates)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Constants.Colors.primaryButton)
                        .padding()
                        .frame(maxWidth: 340)
                        .background(Constants.Colors.highlightHintAffected.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: Constants.Sizing.buttonCornerRadius))
                    }

                    // Technique library
                    Button(action: { showingTechniqueLibrary = true }) {
                        HStack {
                            Image(systemName: "book.fill")
                            Text("Technique Library")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14))
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Constants.Colors.toolbarButton)
                        .padding()
                        .frame(maxWidth: 340)
                        .background(Constants.Colors.highlightRowColBox.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: Constants.Sizing.buttonCornerRadius))
                    }
                }

                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showingLearnMode) {
            LearnModeView()
        }
        .sheet(isPresented: $showingTechniqueLibrary) {
            TechniqueLibraryView()
        }
        .confirmationDialog("Generate Puzzle", isPresented: $showingGenerateOptions, titleVisibility: .visible) {
            ForEach(Difficulty.allCases) { difficulty in
                Button("Generate \(difficulty.rawValue)") {
                    generatePuzzle(difficulty: difficulty)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Select difficulty for the new puzzle")
        }
    }

    private func generatePuzzle(difficulty: Difficulty) {
        isGenerating = true
        // Run generation on background thread to avoid UI freeze
        DispatchQueue.global(qos: .userInitiated).async {
            let puzzle = PuzzleGenerator.generate(difficulty: difficulty)
            DispatchQueue.main.async {
                isGenerating = false
                generatedPuzzle = puzzle
                selectedDifficulty = difficulty
                isShowingGame = true
            }
        }
    }
}

/// Button for selecting difficulty
struct DifficultyButton: View {
    let difficulty: Difficulty
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.rawValue)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)

                    Text(difficulty.description)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .frame(maxWidth: 340)
            .background(difficulty.color)
            .clipShape(RoundedRectangle(cornerRadius: Constants.Sizing.buttonCornerRadius))
        }
    }
}

#Preview {
    MainMenuView(
        selectedDifficulty: .constant(nil),
        isShowingGame: .constant(false),
        generatedPuzzle: .constant(nil)
    )
}
