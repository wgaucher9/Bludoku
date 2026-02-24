import SwiftUI

struct SudokuCellView: View {
    let cell: CellData
    let isSelected: Bool
    let isHighlighted: Bool
    let isSameNumber: Bool
    let isInvalid: Bool

    var body: some View {
        ZStack {
            backgroundColor

            if !cell.isEmpty {
                Text("\(cell.displayValue)")
                    .font(.system(size: 20, weight: cell.isGiven ? .bold : .regular, design: .rounded))
                    .foregroundColor(foregroundColor)
                    .animation(.none, value: cell.displayValue)
            }
        }
    }

    // MARK: - Colors

    private var backgroundColor: Color {
        if isSelected    { return Color.blue.opacity(0.45) }
        if isSameNumber  { return Color.blue.opacity(0.22) }
        if isHighlighted { return Color.blue.opacity(0.09) }
        return Color(.systemBackground)
    }

    private var foregroundColor: Color {
        if isInvalid   { return .red }
        if cell.isGiven { return Color(.label) }
        return .blue
    }
}
