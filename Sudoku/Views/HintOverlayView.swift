import SwiftUI

/// Overlay that shows technique hints with detailed step-by-step explanations
struct HintOverlayView: View {
    let hint: TechniqueHint
    let onApply: () -> Void
    let onDismiss: () -> Void

    @State private var currentStep = 0
    @State private var showAllSteps = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 12)

                Divider()

                // Content - either step-by-step or quick summary
                if hint.detailedSteps.isEmpty {
                    quickExplanationView
                        .padding(20)
                } else if showAllSteps {
                    allStepsView
                } else {
                    stepByStepView
                }

                Divider()

                // Action buttons
                actionButtonsView
                    .padding(20)
            }
            .background(Constants.Colors.background)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: -5)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Header

    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(hint.technique.rawValue)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Constants.Colors.primaryButton)

                HStack(spacing: 8) {
                    Text(hint.technique.category.rawValue)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(difficultyColor)
                        .clipShape(Capsule())

                    if !hint.detailedSteps.isEmpty {
                        Text("\(hint.detailedSteps.count) steps")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Constants.Colors.candidates)
                    }
                }
            }

            Spacer()

            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Constants.Colors.candidates.opacity(0.6))
            }
        }
    }

    private var difficultyColor: Color {
        switch hint.technique.category {
        case .basic: return Constants.Colors.easyColor
        case .intermediate: return Constants.Colors.mediumColor
        case .advanced: return Constants.Colors.hardColor
        }
    }

    // MARK: - Quick Explanation (fallback)

    private var quickExplanationView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(hint.explanation)
                .font(.system(size: 17))
                .foregroundColor(Constants.Colors.toolbarButton)
                .fixedSize(horizontal: false, vertical: true)

            if hint.candidates.count == 1, let value = hint.candidates.first {
                answerBadge(value: value)
            }
        }
    }

    // MARK: - Step by Step View

    private var stepByStepView: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack(spacing: 6) {
                ForEach(0..<hint.detailedSteps.count, id: \.self) { index in
                    Circle()
                        .fill(index <= currentStep ? Constants.Colors.primaryButton : Constants.Colors.disabledButton.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
                Spacer()

                Button(action: { showAllSteps = true }) {
                    Text("Show all")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Constants.Colors.primaryButton)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            // Current step content
            if currentStep < hint.detailedSteps.count {
                let step = hint.detailedSteps[currentStep]

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        if !step.emoji.isEmpty {
                            Text(step.emoji)
                                .font(.system(size: 24))
                        }
                        Text(step.title)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Constants.Colors.toolbarButton)
                    }

                    Text(step.explanation)
                        .font(.system(size: 16))
                        .foregroundColor(Constants.Colors.toolbarButton.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(3)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(.easeInOut(duration: 0.2), value: currentStep)
            }

            // Navigation buttons
            HStack(spacing: 12) {
                if currentStep > 0 {
                    Button(action: { currentStep -= 1 }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Constants.Colors.toolbarButton)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Constants.Colors.highlightRowColBox)
                        .clipShape(Capsule())
                    }
                }

                Spacer()

                if currentStep < hint.detailedSteps.count - 1 {
                    Button(action: { currentStep += 1 }) {
                        HStack(spacing: 6) {
                            Text("Next")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Constants.Colors.primaryButton)
                        .clipShape(Capsule())
                    }
                } else {
                    // Show answer on last step
                    if hint.candidates.count == 1, let value = hint.candidates.first {
                        answerBadge(value: value)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }

    // MARK: - All Steps View

    private var allStepsView: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: { showAllSteps = false }) {
                    Text("Step by step")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Constants.Colors.primaryButton)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(Array(hint.detailedSteps.enumerated()), id: \.element.id) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            // Step number
                            ZStack {
                                Circle()
                                    .fill(Constants.Colors.primaryButton)
                                    .frame(width: 28, height: 28)
                                Text("\(index + 1)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 8) {
                                    if !step.emoji.isEmpty {
                                        Text(step.emoji)
                                            .font(.system(size: 18))
                                    }
                                    Text(step.title)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(Constants.Colors.toolbarButton)
                                }

                                Text(step.explanation)
                                    .font(.system(size: 15))
                                    .foregroundColor(Constants.Colors.toolbarButton.opacity(0.85))
                                    .fixedSize(horizontal: false, vertical: true)
                                    .lineSpacing(2)
                            }
                        }
                    }

                    // Show answer at the end
                    if hint.candidates.count == 1, let value = hint.candidates.first {
                        HStack {
                            Spacer()
                            answerBadge(value: value)
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(20)
            }
            .frame(maxHeight: 320)
        }
    }

    // MARK: - Answer Badge

    private func answerBadge(value: Int) -> some View {
        HStack(spacing: 10) {
            Text("Answer:")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Constants.Colors.candidates)

            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Constants.Colors.primaryButton)
                .frame(width: 48, height: 48)
                .background(Constants.Colors.highlightHintAffected)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Action Buttons

    private var actionButtonsView: some View {
        HStack(spacing: 12) {
            Button(action: onDismiss) {
                Text("Got it!")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Constants.Colors.toolbarButton)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Constants.Colors.highlightRowColBox)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button(action: onApply) {
                Text("Place it for me")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Constants.Colors.primaryButton)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3)
            .ignoresSafeArea()

        HintOverlayView(
            hint: TechniqueHint(
                technique: .nakedSingle,
                affectedCells: [40],
                eliminationCells: [],
                candidates: [5],
                explanation: "Cell R5C5 can only be 5. All other numbers (1-9) are already present in its row, column, or box.",
                detailedSteps: [
                    HintStep(title: "Look at cell R5C5", explanation: "This cell is empty. Let's figure out what number can go here by checking what's NOT possible.", highlightCells: [40], emoji: "🔍"),
                    HintStep(title: "Check Row 5", explanation: "Looking across this row, we already have: 1, 2, 3, 4, 6, 7, 8. So our cell can't be any of these numbers.", highlightCells: [], emoji: "➡️"),
                    HintStep(title: "Check Column 5", explanation: "Looking down this column, we already have: 9. This is also ruled out.", highlightCells: [], emoji: "⬇️"),
                    HintStep(title: "Only one number left!", explanation: "We've eliminated 1, 2, 3, 4, 6, 7, 8, 9 from the possibilities. The ONLY number that can go in this cell is 5.", highlightCells: [40], emoji: "✅")
                ]
            ),
            onApply: {},
            onDismiss: {}
        )
    }
}
