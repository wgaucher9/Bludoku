import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SudokuViewModel()
    @State private var showStats = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Puzzle info bar
                if let puzzle = viewModel.currentPuzzle {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Puzzle \(puzzle.id)")
                                .font(.headline)
                            Text(viewModel.puzzleCountLabel)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if viewModel.isCurrentPuzzleCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title3)
                        }
                        DifficultyBadge(difficulty: puzzle.difficulty)
                    }
                    .padding(.horizontal)
                }

                // 9×9 grid
                SudokuGridView(viewModel: viewModel)
                    .padding(.horizontal, 12)

                // Number input pad
                NumberPadView(viewModel: viewModel)
                    .padding(.bottom, 4)

                // Puzzle navigation
                HStack {
                    Button(action: viewModel.previousPuzzle) {
                        Label("Previous", systemImage: "chevron.left")
                    }
                    .disabled(!viewModel.hasPreviousPuzzle)

                    Spacer()

                    Button(action: viewModel.requestNextPuzzle) {
                        Label("Next", systemImage: "chevron.right")
                            .labelStyle(.titleAndIcon)
                    }
                    .disabled(!viewModel.hasNextPuzzle)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .navigationTitle("Bludoku")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showStats = true } label: {
                        Image(systemName: "chart.bar")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.loadPuzzle(at: viewModel.currentPuzzleIndex)
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    .help("Restart puzzle")
                }
            }
        }
        .sheet(isPresented: $showStats) {
            StatsView(records: viewModel.completionRecords,
                      puzzleCount: viewModel.puzzles.count)
        }
        .alert("Unsolved Entries", isPresented: $viewModel.showNextPuzzleConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Start New Puzzle", role: .destructive) { viewModel.nextPuzzle() }
        } message: {
            Text("You have unsolved entries. Start a new puzzle?")
        }
        .alert("Puzzle Complete!", isPresented: $viewModel.showCongratulations) {
            if viewModel.hasNextPuzzle {
                Button("Next Puzzle") { viewModel.nextPuzzle() }
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text("Congratulations! You solved the puzzle correctly.")
        }
    }
}

// MARK: - Difficulty badge

struct DifficultyBadge: View {
    let difficulty: String

    private var color: Color {
        switch difficulty.lowercased() {
        case "easy":   return .green
        case "medium": return .orange
        case "hard":   return .red
        default:       return .blue
        }
    }

    var body: some View {
        Text(difficulty.capitalized)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}
