import SwiftUI

/// Number pad for entering digits 1-9
struct NumberPadView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        HStack(spacing: Constants.Sizing.numberPadSpacing) {
            ForEach(1...9, id: \.self) { number in
                NumberButton(
                    number: number,
                    isComplete: viewModel.isNumberComplete(number),
                    isNotesMode: viewModel.isNotesMode
                ) {
                    viewModel.enterNumber(number)
                }
            }
        }
    }
}

/// Individual number button
struct NumberButton: View {
    let number: Int
    let isComplete: Bool
    let isNotesMode: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(number)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(buttonForeground)
                .frame(width: Constants.Sizing.numberPadButtonSize, height: Constants.Sizing.numberPadButtonSize)
                .background(buttonBackground)
                .clipShape(RoundedRectangle(cornerRadius: Constants.Sizing.buttonCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.Sizing.buttonCornerRadius)
                        .stroke(borderColor, lineWidth: isNotesMode ? 3 : 0)
                )
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .disabled(isComplete)
        .opacity(isComplete ? 0.4 : 1.0)
    }

    private var buttonForeground: Color {
        isComplete ? Constants.Colors.disabledButton : Constants.Colors.primaryButton
    }

    private var buttonBackground: Color {
        Constants.Colors.highlightRowColBox.opacity(0.8)
    }

    private var borderColor: Color {
        isNotesMode ? Constants.Colors.primaryButton : .clear
    }
}

/// Compact number pad for smaller screens (3x3 grid)
struct CompactNumberPadView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: Constants.Sizing.numberPadSpacing) {
            ForEach(0..<3) { row in
                HStack(spacing: Constants.Sizing.numberPadSpacing) {
                    ForEach(0..<3) { col in
                        let number = row * 3 + col + 1
                        NumberButton(
                            number: number,
                            isComplete: viewModel.isNumberComplete(number),
                            isNotesMode: viewModel.isNotesMode
                        ) {
                            viewModel.enterNumber(number)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        let puzzle = PuzzleStore.shared.easyPuzzles.first!
        let viewModel = GameViewModel(puzzle: puzzle)

        NumberPadView(viewModel: viewModel)

        CompactNumberPadView(viewModel: viewModel)
    }
    .padding()
}
