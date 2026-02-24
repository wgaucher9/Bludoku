import SwiftUI

struct SudokuGridView: View {
    @ObservedObject var viewModel: SudokuViewModel

    var body: some View {
        GeometryReader { geo in
            let size     = min(geo.size.width, geo.size.height)
            let cellSize = size / 9

            ZStack(alignment: .topLeading) {
                // Cell grid
                VStack(spacing: 0) {
                    ForEach(0..<9, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<9, id: \.self) { col in
                                SudokuCellView(
                                    cell:          viewModel.cells[row][col],
                                    isSelected:    viewModel.isSelected(row: row, col: col),
                                    isHighlighted: viewModel.isHighlighted(row: row, col: col),
                                    isSameNumber:  viewModel.isSameNumber(row: row, col: col),
                                    isInvalid:     viewModel.isInvalid(row: row, col: col)
                                )
                                .frame(width: cellSize, height: cellSize)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.selectCell(row: row, col: col)
                                }
                            }
                        }
                    }
                }
                .frame(width: cellSize * 9, height: cellSize * 9)

                // Grid lines drawn on top (non-interactive)
                GridLinesView(cellSize: cellSize, totalSize: size)
                    .allowsHitTesting(false)
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Grid line overlay

private struct GridLinesView: View {
    let cellSize: CGFloat
    let totalSize: CGFloat

    var body: some View {
        Canvas { context, _ in
            // Thin cell lines, thick box border lines
            for i in 1..<9 {
                let pos        = cellSize * CGFloat(i)
                let isBoxEdge  = i % 3 == 0
                let lineWidth: CGFloat = isBoxEdge ? 2.5 : 0.5
                let color      = isBoxEdge
                    ? Color(.label).opacity(0.75)
                    : Color(.label).opacity(0.25)

                drawLine(context,
                         from: CGPoint(x: pos, y: 0),
                         to:   CGPoint(x: pos, y: totalSize),
                         color: color, width: lineWidth)

                drawLine(context,
                         from: CGPoint(x: 0,         y: pos),
                         to:   CGPoint(x: totalSize,  y: pos),
                         color: color, width: lineWidth)
            }

            // Outer border
            var border = Path()
            border.addRect(CGRect(x: 0, y: 0, width: totalSize, height: totalSize))
            context.stroke(border,
                           with: .color(Color(.label).opacity(0.75)),
                           lineWidth: 2.5)
        }
        .frame(width: totalSize, height: totalSize)
    }

    private func drawLine(_ ctx: GraphicsContext,
                          from start: CGPoint,
                          to end: CGPoint,
                          color: Color,
                          width: CGFloat) {
        var path = Path()
        path.move(to: start)
        path.addLine(to: end)
        ctx.stroke(path, with: .color(color), lineWidth: width)
    }
}
