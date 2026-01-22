import SwiftUI

/// Library of Sudoku solving techniques
struct TechniqueLibraryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTechnique: TechniqueType?

    var body: some View {
        NavigationView {
            List {
                ForEach(TechniqueCategory.allCases, id: \.self) { category in
                    Section(header: Text(category.rawValue)) {
                        ForEach(techniquesInCategory(category)) { technique in
                            TechniqueRow(technique: technique) {
                                selectedTechnique = technique
                            }
                        }
                    }
                }
            }
            .navigationTitle("Techniques")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedTechnique) { technique in
                TechniqueTutorialView(technique: technique)
            }
        }
    }

    private func techniquesInCategory(_ category: TechniqueCategory) -> [TechniqueType] {
        TechniqueType.allCases.filter { $0.category == category }
    }
}

/// Row displaying a technique in the library
struct TechniqueRow: View {
    let technique: TechniqueType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(technique.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Constants.Colors.toolbarButton)

                    Text(technique.description)
                        .font(.system(size: 12))
                        .foregroundColor(Constants.Colors.candidates)
                        .lineLimit(2)
                }

                Spacer()

                // Difficulty indicator
                DifficultyIndicator(difficulty: technique.difficulty)

                Image(systemName: "chevron.right")
                    .foregroundColor(Constants.Colors.candidates)
            }
            .padding(.vertical, 4)
        }
    }
}

/// Small indicator showing technique difficulty
struct DifficultyIndicator: View {
    let difficulty: Difficulty

    var body: some View {
        Text(difficulty.rawValue)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(difficulty.color)
            .clipShape(Capsule())
    }
}

#Preview {
    TechniqueLibraryView()
}
