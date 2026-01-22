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

/// Large prominent Notes button with clear on/off state
struct NotesButton: View {
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    // Background circle
                    Circle()
                        .fill(isActive ? Constants.Colors.mediumColor : Constants.Colors.highlightRowColBox)
                        .frame(width: Constants.Sizing.toolbarButtonSizeLarge, height: Constants.Sizing.toolbarButtonSizeLarge)

                    // Border when off
                    if !isActive {
                        Circle()
                            .stroke(Constants.Colors.primaryButton.opacity(0.5), lineWidth: 2)
                            .frame(width: Constants.Sizing.toolbarButtonSizeLarge, height: Constants.Sizing.toolbarButtonSizeLarge)
                    }

                    // Icon
                    Image(systemName: isActive ? "pencil.tip.crop.circle.fill" : "pencil.tip")
                        .font(.system(size: isActive ? 32 : 26, weight: .semibold))
                        .foregroundColor(isActive ? .white : Constants.Colors.primaryButton)
                }

                // Label with ON/OFF indicator
                HStack(spacing: 4) {
                    Text("Notes")
                        .font(.system(size: 13, weight: .semibold))

                    if isActive {
                        Text("ON")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Constants.Colors.mediumColor)
                            .clipShape(Capsule())
                    }
                }
                .foregroundColor(isActive ? Constants.Colors.mediumColor : Constants.Colors.primaryButton)
            }
        }
        .padding(.horizontal, 4)
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}

#Preview {
    ToolbarView(viewModel: GameViewModel(difficulty: .easy))
        .padding()
}
