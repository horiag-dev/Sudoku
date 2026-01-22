import SwiftUI

/// Displays game statistics (difficulty, mistakes, timer)
struct StatsBarView: View {
    @ObservedObject var viewModel: GameViewModel
    let onPause: () -> Void

    var body: some View {
        HStack {
            // Difficulty badge
            DifficultyBadge(difficulty: viewModel.difficulty)

            Spacer()

            // Mistakes counter
            MistakesView(
                mistakes: viewModel.mistakes,
                maxMistakes: viewModel.maxMistakes
            )

            Spacer()

            // Timer
            TimerView(
                time: viewModel.formattedTime,
                onPause: onPause
            )
        }
        .padding(.horizontal)
    }
}

/// Badge showing current difficulty
struct DifficultyBadge: View {
    let difficulty: Difficulty

    var body: some View {
        Text(difficulty.rawValue)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(difficulty.color)
            .clipShape(Capsule())
    }
}

/// Shows mistakes count
struct MistakesView: View {
    let mistakes: Int
    let maxMistakes: Int

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(mistakes > 0 ? Constants.Colors.errorNumber : Constants.Colors.candidates)

            Text("Mistakes: \(mistakes)/\(maxMistakes)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Constants.Colors.toolbarButton)
        }
    }
}

/// Timer display with pause button
struct TimerView: View {
    let time: String
    let onPause: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock")
                .foregroundColor(Constants.Colors.toolbarButton)

            Text(time)
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundColor(Constants.Colors.toolbarButton)

            Button(action: onPause) {
                Image(systemName: "pause.fill")
                    .foregroundColor(Constants.Colors.primaryButton)
            }
        }
    }
}

#Preview {
    let puzzle = PuzzleStore.shared.easyPuzzles.first!
    let viewModel = GameViewModel(puzzle: puzzle)

    return VStack {
        StatsBarView(viewModel: viewModel, onPause: {})
    }
    .padding()
}
