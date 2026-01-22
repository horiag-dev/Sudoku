import SwiftUI

/// Learn mode - practice specific techniques with guided examples
struct LearnModeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPuzzle: TechniquePractice.PracticePuzzle?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Learn Mode")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Constants.Colors.primaryButton)

                        Text("Practice each technique with guided examples")
                            .font(.system(size: 15))
                            .foregroundColor(Constants.Colors.candidates)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)

                    // Technique sections
                    ForEach(TechniquePractice.shared.puzzlesByTechnique, id: \.technique) { item in
                        TechniquePracticeSection(
                            technique: item.technique,
                            puzzles: item.puzzles,
                            onSelect: { selectedPuzzle = $0 }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .background(Constants.Colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 17, weight: .semibold))
                }
            }
            .fullScreenCover(item: $selectedPuzzle) { puzzle in
                PracticeGameView(practicePuzzle: puzzle)
            }
        }
    }
}

/// Section showing practice puzzles for one technique
struct TechniquePracticeSection: View {
    let technique: TechniqueType
    let puzzles: [TechniquePractice.PracticePuzzle]
    let onSelect: (TechniquePractice.PracticePuzzle) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Technique header
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(technique.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Constants.Colors.toolbarButton)

                    Text(technique.shortDescription)
                        .font(.system(size: 13))
                        .foregroundColor(Constants.Colors.candidates)
                }

                Spacer()

                DifficultyIndicator(difficulty: technique.difficulty)
            }

            // Practice puzzles
            ForEach(Array(puzzles.enumerated()), id: \.element.id) { index, puzzle in
                PracticePuzzleCard(
                    puzzle: puzzle,
                    number: index + 1,
                    onTap: { onSelect(puzzle) }
                )
            }
        }
        .padding(16)
        .background(Constants.Colors.highlightRowColBox.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

/// Card for a single practice puzzle
struct PracticePuzzleCard: View {
    let puzzle: TechniquePractice.PracticePuzzle
    let number: Int
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Number badge
                Text("\(number)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Constants.Colors.primaryButton)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(puzzle.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Constants.Colors.toolbarButton)

                    Text(puzzle.description)
                        .font(.system(size: 13))
                        .foregroundColor(Constants.Colors.candidates)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Constants.Colors.primaryButton)
            }
            .padding(12)
            .background(Constants.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

/// Game view specifically for practice mode
struct PracticeGameView: View {
    let practicePuzzle: TechniquePractice.PracticePuzzle
    @StateObject private var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingHintPrompt = true

    init(practicePuzzle: TechniquePractice.PracticePuzzle) {
        self.practicePuzzle = practicePuzzle
        _viewModel = StateObject(wrappedValue: GameViewModel(puzzle: practicePuzzle.puzzle))
    }

    var body: some View {
        ZStack {
            Constants.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Constants.Colors.toolbarButton)
                    }

                    Spacer()

                    VStack(spacing: 2) {
                        Text("Learning: \(practicePuzzle.technique.rawValue)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Constants.Colors.primaryButton)

                        Text(practicePuzzle.title)
                            .font(.system(size: 13))
                            .foregroundColor(Constants.Colors.candidates)
                    }

                    Spacer()

                    Button(action: { viewModel.useHint() }) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Constants.Colors.mediumColor)
                    }
                }
                .padding(.horizontal)

                // Instruction card
                if showingHintPrompt {
                    InstructionCard(
                        technique: practicePuzzle.technique,
                        description: practicePuzzle.description,
                        onDismiss: { showingHintPrompt = false },
                        onShowHint: {
                            showingHintPrompt = false
                            viewModel.useHint()
                        }
                    )
                    .padding(.horizontal)
                }

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

            // Hint overlay
            if viewModel.showingHint, let hint = viewModel.activeHint {
                HintOverlayView(
                    hint: hint,
                    onApply: { viewModel.applyHint() },
                    onDismiss: { viewModel.dismissHint() }
                )
            }

            // Completion overlay
            if viewModel.isCompleted {
                CompletionOverlay(
                    technique: practicePuzzle.technique,
                    onContinue: { dismiss() }
                )
            }
        }
    }
}

/// Instruction card shown at the start of practice
struct InstructionCard: View {
    let technique: TechniqueType
    let description: String
    let onDismiss: () -> Void
    let onShowHint: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "graduationcap.fill")
                    .foregroundColor(Constants.Colors.primaryButton)
                Text("Your Goal")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Constants.Colors.toolbarButton)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Constants.Colors.candidates)
                }
            }

            Text(description)
                .font(.system(size: 15))
                .foregroundColor(Constants.Colors.toolbarButton)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                Button(action: onDismiss) {
                    Text("I'll try it!")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.toolbarButton)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Constants.Colors.highlightRowColBox)
                        .clipShape(Capsule())
                }

                Button(action: onShowHint) {
                    Text("Show me how")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Constants.Colors.primaryButton)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(Constants.Colors.highlightHintAffected.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

/// Completion overlay for practice mode
struct CompletionOverlay: View {
    let technique: TechniqueType
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Constants.Colors.easyColor)

                Text("Great job!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Constants.Colors.toolbarButton)

                Text("You've practiced the \(technique.rawValue) technique!")
                    .font(.system(size: 16))
                    .foregroundColor(Constants.Colors.candidates)
                    .multilineTextAlignment(.center)

                Button(action: onContinue) {
                    Text("Continue Learning")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Constants.Colors.primaryButton)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top, 8)
            }
            .padding(32)
            .background(Constants.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 20)
        }
    }
}

#Preview {
    LearnModeView()
}
