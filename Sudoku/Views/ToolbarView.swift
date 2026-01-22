import SwiftUI

/// Toolbar with game action buttons
struct ToolbarView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        HStack(spacing: Constants.Sizing.toolbarSpacing - 4) {
            // Undo button
            ToolbarButton(
                icon: "arrow.uturn.backward",
                label: "Undo",
                isEnabled: viewModel.canUndo,
                action: viewModel.undo
            )

            // Erase button
            ToolbarButton(
                icon: "eraser",
                label: "Erase",
                isEnabled: viewModel.selectedCellIndex != nil,
                action: viewModel.eraseSelectedCell
            )

            // Notes toggle - larger and more prominent
            NotesButton(
                isActive: viewModel.isNotesMode,
                action: viewModel.toggleNotesMode
            )

            // Check solvable button
            ToolbarButton(
                icon: "checkmark.circle",
                label: "Check",
                isEnabled: !viewModel.isCompleted,
                action: viewModel.checkSolvability
            )

            // Hint button
            ToolbarButton(
                icon: "lightbulb",
                label: "Hint",
                isEnabled: !viewModel.isCompleted,
                action: viewModel.useHint
            )

            // Learn button - explore techniques on current puzzle
            ToolbarButton(
                icon: "book",
                label: "Learn",
                isEnabled: !viewModel.isCompleted,
                action: viewModel.openTechniqueExplorer
            )
        }
    }
}

/// Individual toolbar button
struct ToolbarButton: View {
    let icon: String
    let label: String
    var isActive: Bool = false
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(iconColor)
                    .frame(width: Constants.Sizing.toolbarButtonSize, height: Constants.Sizing.toolbarButtonSize)
                    .background(backgroundColor)
                    .clipShape(Circle())

                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(labelColor)
            }
        }
        .disabled(!isEnabled)
    }

    private var iconColor: Color {
        if !isEnabled {
            return Constants.Colors.disabledButton
        }
        return isActive ? .white : Constants.Colors.toolbarButton
    }

    private var backgroundColor: Color {
        if isActive {
            return Constants.Colors.toolbarButtonActive
        }
        return Constants.Colors.highlightRowColBox.opacity(0.5)
    }

    private var labelColor: Color {
        isEnabled ? Constants.Colors.toolbarButton : Constants.Colors.disabledButton
    }
}

/// Large prominent Notes button
struct NotesButton: View {
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: "pencil.tip")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(isActive ? .white : Constants.Colors.primaryButton)
                    .frame(width: Constants.Sizing.toolbarButtonSizeLarge, height: Constants.Sizing.toolbarButtonSizeLarge)
                    .background(isActive ? Constants.Colors.primaryButton : Constants.Colors.highlightSelected.opacity(0.6))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Constants.Colors.primaryButton, lineWidth: isActive ? 0 : 2)
                    )

                Text("Notes")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Constants.Colors.primaryButton)
            }
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    ToolbarView(viewModel: GameViewModel(difficulty: .easy))
        .padding()
}
