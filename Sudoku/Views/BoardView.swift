import SwiftUI

/// View for the entire 9x9 Sudoku board
struct BoardView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        Grid(horizontalSpacing: 0, verticalSpacing: 0) {
            ForEach(0..<9, id: \.self) { row in
                GridRow {
                    ForEach(0..<9, id: \.self) { col in
                        let index = row * 9 + col
                        let cell = viewModel.board.cells[index]

                        CellView(
                            cell: cell,
                            highlightType: viewModel.highlightType(for: index),
                            isSelected: viewModel.selectedCellIndex == index,
                            onTap: {
                                viewModel.selectCell(at: index)
                            }
                        )
                        .overlay(alignment: .trailing) {
                            if col < 8 {
                                Rectangle()
                                    .fill(lineColor(col: col))
                                    .frame(width: lineWidth(col: col))
                            }
                        }
                        .overlay(alignment: .bottom) {
                            if row < 8 {
                                Rectangle()
                                    .fill(lineColor(row: row))
                                    .frame(height: lineWidth(row: row))
                            }
                        }
                    }
                }
            }
        }
        .background(Constants.Colors.gridBackground)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Constants.Colors.thickLine, lineWidth: 2)
        )
    }

    private func lineWidth(col: Int) -> CGFloat {
        (col + 1) % 3 == 0 ? 2 : 1
    }

    private func lineWidth(row: Int) -> CGFloat {
        (row + 1) % 3 == 0 ? 2 : 1
    }

    private func lineColor(col: Int) -> Color {
        (col + 1) % 3 == 0 ? Constants.Colors.thickLine : Constants.Colors.thinLine
    }

    private func lineColor(row: Int) -> Color {
        (row + 1) % 3 == 0 ? Constants.Colors.thickLine : Constants.Colors.thinLine
    }
}

#Preview {
    let puzzle = PuzzleStore.shared.easyPuzzles.first!
    let viewModel = GameViewModel(puzzle: puzzle)
    viewModel.selectCell(at: 40)

    return BoardView(viewModel: viewModel)
        .padding()
}
