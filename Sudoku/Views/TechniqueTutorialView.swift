import SwiftUI

/// Interactive tutorial for learning a solving technique
struct TechniqueTutorialView: View {
    let technique: TechniqueType
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0

    private var lesson: TechniqueLesson? {
        TechniqueLessons.allLessons.first { $0.technique == technique }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(technique.rawValue)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Constants.Colors.primaryButton)

                    DifficultyIndicator(difficulty: technique.difficulty)
                }
                .padding(.top)

                // Description
                Text(technique.description)
                    .font(.system(size: 16))
                    .foregroundColor(Constants.Colors.toolbarButton)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Divider()
                    .padding(.horizontal)

                // Steps
                if let lesson = lesson {
                    StepsView(lesson: lesson, currentStep: $currentStep)
                } else {
                    // Fallback for techniques without detailed lessons
                    GenericTutorialView(technique: technique)
                }

                Spacer()

                // Navigation buttons
                if let lesson = lesson {
                    StepNavigationView(
                        currentStep: $currentStep,
                        totalSteps: lesson.steps.count
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// Displays tutorial steps
struct StepsView: View {
    let lesson: TechniqueLesson
    @Binding var currentStep: Int

    var body: some View {
        TabView(selection: $currentStep) {
            ForEach(Array(lesson.steps.enumerated()), id: \.offset) { index, step in
                VStack(spacing: 16) {
                    Text("Step \(index + 1)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.primaryButton)

                    Text(step.title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Constants.Colors.toolbarButton)

                    Text(step.description)
                        .font(.system(size: 16))
                        .foregroundColor(Constants.Colors.candidates)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    // Placeholder for interactive example
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Constants.Colors.highlightRowColBox)
                        .frame(height: 200)
                        .overlay(
                            Text("Interactive Example")
                                .foregroundColor(Constants.Colors.candidates)
                        )
                        .padding(.horizontal, 24)
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

/// Navigation buttons for moving between steps
struct StepNavigationView: View {
    @Binding var currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 16) {
            // Previous button
            Button(action: { currentStep = max(0, currentStep - 1) }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Previous")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(currentStep > 0 ? Constants.Colors.primaryButton : Constants.Colors.disabledButton)
            }
            .disabled(currentStep <= 0)

            // Step indicators
            HStack(spacing: 8) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Circle()
                        .fill(index == currentStep ? Constants.Colors.primaryButton : Constants.Colors.highlightRowColBox)
                        .frame(width: 8, height: 8)
                }
            }

            // Next button
            Button(action: { currentStep = min(totalSteps - 1, currentStep + 1) }) {
                HStack {
                    Text(currentStep < totalSteps - 1 ? "Next" : "Finish")
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Constants.Colors.primaryButton)
            }
        }
        .padding()
    }
}

/// Generic tutorial view for techniques without detailed lessons
struct GenericTutorialView: View {
    let technique: TechniqueType

    var body: some View {
        VStack(spacing: 24) {
            Text("How to Use")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Constants.Colors.toolbarButton)

            VStack(alignment: .leading, spacing: 16) {
                TutorialStep(number: 1, text: "Look for patterns in the grid that match this technique")
                TutorialStep(number: 2, text: "Identify which cells are affected")
                TutorialStep(number: 3, text: "Apply the elimination or placement")
                TutorialStep(number: 4, text: "Continue solving with the simplified candidates")
            }
            .padding(.horizontal, 32)
        }
    }
}

struct TutorialStep: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Constants.Colors.primaryButton)
                .clipShape(Circle())

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Constants.Colors.candidates)
        }
    }
}

#Preview {
    TechniqueTutorialView(technique: .nakedSingle)
}
