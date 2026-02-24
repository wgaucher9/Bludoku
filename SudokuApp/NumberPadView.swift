import SwiftUI

struct NumberPadView: View {
    @ObservedObject var viewModel: SudokuViewModel

    var body: some View {
        VStack(spacing: 10) {
            // Digit buttons 1–9
            HStack(spacing: 6) {
                ForEach(1...9, id: \.self) { digit in
                    DigitButton(digit: digit) {
                        viewModel.enterNumber(digit)
                    }
                }
            }

            // Action buttons
            HStack(spacing: 12) {
                ActionButton(title: "Erase", icon: "delete.left") {
                    viewModel.eraseSelected()
                }

                ActionButton(title: "Check", icon: "checkmark.circle", tint: .blue) {
                    viewModel.validate()
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Sub-components

private struct DigitButton: View {
    let digit: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(digit)")
                .font(.system(size: 22, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
        .foregroundColor(.primary)
    }
}

private struct ActionButton: View {
    let title: String
    let icon: String
    var tint: Color = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 15, weight: .medium))
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .foregroundColor(tint)
        }
        .buttonStyle(.plain)
    }
}
