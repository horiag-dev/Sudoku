import SwiftUI

/// View for a single Sudoku cell
struct CellView: View {
    let cell: Cell
    let highlightType: CellHighlightType
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        ZStack {
            // Background
            backgroundColor
                .animation(Constants.Animation.quick, value: highlightType)

            // Content
            if let value = cell.value {
                // Display the number
                Text("\(value)")
                    .font(.system(size: Constants.Sizing.cellFontSize, weight: cell.isGiven ? .bold : .medium, design: .rounded))
                    .foregroundColor(numberColor)
            } else if !cell.candidates.isEmpty {
                // Display candidates in 3x3 grid
                CandidatesGrid(candidates: cell.candidates)
            }
        }
        .frame(width: Constants.Sizing.cellSize, height: Constants.Sizing.cellSize)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }

    private var backgroundColor: Color {
        switch highlightType {
        case .selected:
            return Constants.Colors.highlightSelected
        case .sameNumber:
            return Constants.Colors.highlightSameNumber
        case .rowColBox:
            return Constants.Colors.highlightRowColBox
        case .error:
            return Constants.Colors.errorNumber.opacity(0.2)
        case .hintAffected:
            return Constants.Colors.highlightHintAffected
        case .hintElimination:
            return Constants.Colors.highlightHintElimination
        case .none:
            return Constants.Colors.gridBackground
        }
    }

    private var numberColor: Color {
        if cell.isError {
            return Constants.Colors.errorNumber
        } else if cell.isGiven {
            return Constants.Colors.givenNumber
        } else {
            return Constants.Colors.userNumber
        }
    }
}

/// 3x3 grid displaying candidate numbers
struct CandidatesGrid: View {
    let candidates: Set<Int>

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<3) { row in
                HStack(spacing: 0) {
                    ForEach(0..<3) { col in
                        let num = row * 3 + col + 1
                        Text(candidates.contains(num) ? "\(num)" : " ")
                            .font(.system(size: Constants.Sizing.candidateFontSize, weight: .medium, design: .monospaced))
                            .foregroundColor(Constants.Colors.candidates)
                            .frame(width: Constants.Sizing.candidateSize, height: Constants.Sizing.candidateSize)
                    }
                }
            }
        }
    }
}

#Preview {
    HStack {
        CellView(
            cell: Cell(id: 0, value: 5, isGiven: true),
            highlightType: .none,
            isSelected: false,
            onTap: {}
        )

        CellView(
            cell: Cell(id: 1, value: 3),
            highlightType: .selected,
            isSelected: true,
            onTap: {}
        )

        CellView(
            cell: Cell(id: 2, candidates: [1, 3, 7]),
            highlightType: .rowColBox,
            isSelected: false,
            onTap: {}
        )

        CellView(
            cell: Cell(id: 3, value: 9, isError: true),
            highlightType: .none,
            isSelected: false,
            onTap: {}
        )
    }
    .padding()
}
