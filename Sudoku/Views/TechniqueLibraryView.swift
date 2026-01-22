import SwiftUI

/// Library of Sudoku solving techniques with visual examples
struct TechniqueLibraryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTechnique: TechniqueType?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Introduction
                    VStack(spacing: 8) {
                        Text("Technique Library")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Constants.Colors.primaryButton)

                        Text("Learn the patterns that help you solve any Sudoku")
                            .font(.system(size: 15))
                            .foregroundColor(Constants.Colors.candidates)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)

                    // Technique categories
                    ForEach(TechniqueCategory.allCases, id: \.self) { category in
                        TechniqueCategorySection(
                            category: category,
                            techniques: techniquesInCategory(category),
                            onSelect: { selectedTechnique = $0 }
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
            .sheet(item: $selectedTechnique) { technique in
                TechniqueDetailView(technique: technique)
            }
        }
    }

    private func techniquesInCategory(_ category: TechniqueCategory) -> [TechniqueType] {
        TechniqueType.allCases.filter { $0.category == category }
    }
}

/// Section for a category of techniques
struct TechniqueCategorySection: View {
    let category: TechniqueCategory
    let techniques: [TechniqueType]
    let onSelect: (TechniqueType) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category header
            HStack(spacing: 10) {
                Text(category.rawValue)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Constants.Colors.toolbarButton)

                Text(categoryDescription)
                    .font(.system(size: 13))
                    .foregroundColor(Constants.Colors.candidates)

                Spacer()

                categoryBadge
            }

            // Technique cards
            ForEach(techniques) { technique in
                TechniqueCard(technique: technique, onTap: { onSelect(technique) })
            }
        }
    }

    private var categoryDescription: String {
        switch category {
        case .basic: return "Start here"
        case .intermediate: return "Level up"
        case .advanced: return "Expert moves"
        }
    }

    private var categoryBadge: some View {
        Text("\(techniques.count) techniques")
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(categoryColor)
            .clipShape(Capsule())
    }

    private var categoryColor: Color {
        switch category {
        case .basic: return Constants.Colors.easyColor
        case .intermediate: return Constants.Colors.mediumColor
        case .advanced: return Constants.Colors.hardColor
        }
    }
}

/// Card displaying a single technique
struct TechniqueCard: View {
    let technique: TechniqueType
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(technique.rawValue)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Constants.Colors.toolbarButton)

                        Text(technique.shortDescription)
                            .font(.system(size: 14))
                            .foregroundColor(Constants.Colors.candidates)
                            .lineLimit(2)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.candidates)
                }

                // Visual example
                TechniqueVisualExample(technique: technique)
            }
            .padding(16)
            .background(Constants.Colors.highlightRowColBox.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

/// Visual mini-example of a technique
struct TechniqueVisualExample: View {
    let technique: TechniqueType

    var body: some View {
        HStack(spacing: 4) {
            ForEach(exampleCells, id: \.offset) { item in
                MiniCell(
                    value: item.value,
                    candidates: item.candidates,
                    highlight: item.highlight,
                    isElimination: item.isElimination
                )
            }
        }
    }

    private var exampleCells: [(offset: Int, value: Int?, candidates: [Int], highlight: Bool, isElimination: Bool)] {
        switch technique {
        case .nakedSingle:
            return [
                (0, 7, [], false, false),
                (1, nil, [3], true, false),  // Only candidate
                (2, 4, [], false, false)
            ]
        case .hiddenSingle:
            return [
                (0, nil, [2, 5], false, false),
                (1, nil, [5, 8], true, false),  // Hidden 8
                (2, nil, [2, 5], false, false)
            ]
        case .nakedPair:
            return [
                (0, nil, [3, 7], true, false),  // Pair
                (1, nil, [3, 7], true, false),  // Pair
                (2, nil, [3, 5], false, true)   // Elimination
            ]
        case .hiddenPair:
            return [
                (0, nil, [2, 4, 6], true, false),  // Hidden pair
                (1, nil, [2, 4, 9], true, false),  // Hidden pair
                (2, nil, [6, 9], false, false)
            ]
        case .pointingPair:
            return [
                (0, nil, [5], true, false),  // Pointing
                (1, nil, [5], true, false),  // Pointing
                (2, nil, [5], false, true)   // Elimination
            ]
        case .boxLineReduction:
            return [
                (0, nil, [3], true, false),
                (1, nil, [3], true, false),
                (2, nil, [3], false, true)  // Elimination
            ]
        case .xWing:
            return [
                (0, nil, [6], true, false),
                (1, nil, [6], true, false),
                (2, nil, [6], false, true)
            ]
        default:
            return [
                (0, nil, [1, 2], false, false),
                (1, nil, [2, 3], false, false),
                (2, nil, [3, 4], false, false)
            ]
        }
    }
}

/// Mini cell for visual examples
struct MiniCell: View {
    let value: Int?
    let candidates: [Int]
    let highlight: Bool
    let isElimination: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(backgroundColor)
                .frame(width: 36, height: 36)

            if let value = value {
                Text("\(value)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Constants.Colors.givenNumber)
            } else if !candidates.isEmpty {
                Text(candidates.map { String($0) }.joined())
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(isElimination ? Constants.Colors.errorNumber : Constants.Colors.candidates)
                    .strikethrough(isElimination)
            }
        }
    }

    private var backgroundColor: Color {
        if highlight {
            return Constants.Colors.highlightHintAffected
        } else if isElimination {
            return Constants.Colors.highlightHintElimination
        }
        return Constants.Colors.gridBackground
    }
}

/// Detailed view for a single technique
struct TechniqueDetailView: View {
    let technique: TechniqueType
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text(technique.rawValue)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Constants.Colors.primaryButton)

                        HStack(spacing: 12) {
                            DifficultyIndicator(difficulty: technique.difficulty)

                            Text(technique.category.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Constants.Colors.candidates)
                        }
                    }
                    .padding(.top)

                    Divider()

                    // What is it?
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "What is it?", emoji: "🤔")

                        Text(technique.description)
                            .font(.system(size: 16))
                            .foregroundColor(Constants.Colors.toolbarButton)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    // How to spot it
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "How to spot it", emoji: "👀")

                        Text(technique.howToSpot)
                            .font(.system(size: 16))
                            .foregroundColor(Constants.Colors.toolbarButton)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    // Step by step
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Step by step", emoji: "📝")

                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(Array(technique.steps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 26, height: 26)
                                        .background(Constants.Colors.primaryButton)
                                        .clipShape(Circle())

                                    Text(step)
                                        .font(.system(size: 15))
                                        .foregroundColor(Constants.Colors.toolbarButton)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    // Pro tip
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Pro tip", emoji: "💡")

                        Text(technique.proTip)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Constants.Colors.primaryButton)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Constants.Colors.highlightHintAffected.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 32)
                }
            }
            .background(Constants.Colors.background)
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

struct SectionHeader: View {
    let title: String
    let emoji: String

    var body: some View {
        HStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 20))
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Constants.Colors.toolbarButton)
        }
    }
}

/// Row displaying a technique in the library (kept for compatibility)
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
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(difficulty.color)
            .clipShape(Capsule())
    }
}

#Preview {
    TechniqueLibraryView()
}
