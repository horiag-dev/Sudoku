import SwiftUI

/// Overlay for exploring techniques found on the current puzzle
struct TechniqueExplorerView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Learn Techniques")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Constants.Colors.primaryButton)

                        if viewModel.detectedTechniques.isEmpty {
                            Text("No techniques found")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Constants.Colors.candidates)
                        } else {
                            Text("\(viewModel.currentTechniqueIndex + 1) of \(viewModel.detectedTechniques.count)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Constants.Colors.candidates)
                        }
                    }

                    Spacer()

                    Button(action: { viewModel.closeTechniqueExplorer() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Constants.Colors.candidates)
                    }
                }

                Divider()

                if let technique = viewModel.currentTechnique {
                    // Technique info
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(technique.technique.rawValue)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Constants.Colors.toolbarButton)

                            Spacer()

                            Text(technique.technique.category.rawValue)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(technique.technique.difficulty.color)
                                .clipShape(Capsule())
                        }

                        // Technique description
                        Text(technique.technique.description)
                            .font(.system(size: 14))
                            .foregroundColor(Constants.Colors.candidates)
                            .fixedSize(horizontal: false, vertical: true)

                        Divider()

                        // Specific explanation for this instance
                        Text("On your puzzle:")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Constants.Colors.toolbarButton)

                        Text(technique.explanation)
                            .font(.system(size: 14))
                            .foregroundColor(Constants.Colors.toolbarButton)
                            .fixedSize(horizontal: false, vertical: true)

                        // Legend
                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Constants.Colors.highlightHintAffected)
                                    .frame(width: 10, height: 10)
                                Text("Key cells")
                                    .font(.system(size: 11))
                                    .foregroundColor(Constants.Colors.candidates)
                            }

                            if !technique.eliminationCells.isEmpty {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(Constants.Colors.highlightHintElimination)
                                        .frame(width: 10, height: 10)
                                    Text("Eliminations")
                                        .font(.system(size: 11))
                                        .foregroundColor(Constants.Colors.candidates)
                                }
                            }

                            Spacer()
                        }
                    }

                    // Navigation and action buttons
                    HStack(spacing: 12) {
                        // Previous button
                        Button(action: { viewModel.previousTechnique() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(viewModel.currentTechniqueIndex > 0 ? Constants.Colors.primaryButton : Constants.Colors.disabledButton)
                                .frame(width: 44, height: 44)
                                .background(Constants.Colors.highlightRowColBox)
                                .clipShape(Circle())
                        }
                        .disabled(viewModel.currentTechniqueIndex <= 0)

                        // Apply button
                        Button(action: { viewModel.applyCurrentTechnique() }) {
                            Text("Apply This")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Constants.Colors.primaryButton)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        // Next button
                        Button(action: { viewModel.nextTechnique() }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(viewModel.currentTechniqueIndex < viewModel.detectedTechniques.count - 1 ? Constants.Colors.primaryButton : Constants.Colors.disabledButton)
                                .frame(width: 44, height: 44)
                                .background(Constants.Colors.highlightRowColBox)
                                .clipShape(Circle())
                        }
                        .disabled(viewModel.currentTechniqueIndex >= viewModel.detectedTechniques.count - 1)
                    }
                } else {
                    // No techniques found
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(Constants.Colors.candidates)

                        Text("No techniques detected")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Constants.Colors.toolbarButton)

                        Text("Fill in some candidates (notes) first, or try when more cells are empty.")
                            .font(.system(size: 14))
                            .foregroundColor(Constants.Colors.candidates)
                            .multilineTextAlignment(.center)

                        Button(action: { viewModel.closeTechniqueExplorer() }) {
                            Text("Got it")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(Constants.Colors.primaryButton)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .padding(20)
            .background(Constants.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: -5)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

#Preview {
    let viewModel = GameViewModel(difficulty: .easy)
    viewModel.showingTechniqueExplorer = true
    viewModel.detectedTechniques = [
        TechniqueHint(
            technique: .nakedSingle,
            affectedCells: [40],
            eliminationCells: [],
            candidates: [5],
            explanation: "Cell R5C5 can only be 5."
        ),
        TechniqueHint(
            technique: .hiddenSingle,
            affectedCells: [12],
            eliminationCells: [],
            candidates: [3],
            explanation: "In row 2, 3 can only go in cell R2C4."
        )
    ]

    return ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()

        TechniqueExplorerView(viewModel: viewModel)
    }
}
