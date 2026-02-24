import Foundation
import SwiftUI

@MainActor
final class SudokuViewModel: ObservableObject {

    // MARK: - Published state

    @Published private(set) var puzzles: [SudokuPuzzle] = []
    @Published private(set) var currentPuzzleIndex: Int = 0
    @Published var cells: [[CellData]] = SudokuViewModel.emptyGrid()
    @Published var selectedRow: Int? = nil
    @Published var selectedCol: Int? = nil
    @Published var invalidCells: Set<String> = []
    @Published var isComplete = false
    @Published var showCongratulations = false
    @Published var showNextPuzzleConfirmation = false
    @Published private(set) var completionRecords: [CompletionRecord] = []

    // MARK: - Computed helpers

    var currentPuzzle: SudokuPuzzle? {
        guard currentPuzzleIndex < puzzles.count else { return nil }
        return puzzles[currentPuzzleIndex]
    }

    var hasPreviousPuzzle: Bool { currentPuzzleIndex > 0 }
    var hasNextPuzzle:     Bool { currentPuzzleIndex < puzzles.count - 1 }

    var hasUserEntries: Bool {
        cells.contains { row in row.contains { !$0.isGiven && $0.userValue != 0 } }
    }

    func isCompleted(puzzleId: Int) -> Bool {
        completionRecords.contains { $0.puzzleId == puzzleId }
    }

    var isCurrentPuzzleCompleted: Bool {
        guard let puzzle = currentPuzzle else { return false }
        return isCompleted(puzzleId: puzzle.id)
    }

    var puzzleCountLabel: String {
        "\(currentPuzzleIndex + 1) of \(puzzles.count)"
    }

    // MARK: - Init

    init() {
        loadPuzzles()
        loadCompletionRecords()
    }

    // MARK: - Puzzle loading

    func loadPuzzles() {
        guard let url = Bundle.main.url(forResource: "puzzles", withExtension: "json") else {
            print("[loadPuzzles] ERROR: puzzles.json not found in bundle")
            return
        }
        print("[loadPuzzles] Found file at: \(url.path)")

        let data: Data
        do {
            data = try Data(contentsOf: url)
            print("[loadPuzzles] Read \(data.count) bytes")
        } catch {
            print("[loadPuzzles] ERROR reading file: \(error)")
            return
        }

        let collection: PuzzleCollection
        do {
            collection = try JSONDecoder().decode(PuzzleCollection.self, from: data)
        } catch {
            print("[loadPuzzles] ERROR decoding JSON: \(error)")
            return
        }

        puzzles = collection.puzzles
        print("[loadPuzzles] Loaded \(puzzles.count) puzzle(s)")
        if !puzzles.isEmpty { loadPuzzle(at: 0) }
    }

    func loadPuzzle(at index: Int) {
        guard index < puzzles.count else { return }
        currentPuzzleIndex = index
        cells = puzzles[index].puzzle.map { row in row.map { CellData(givenValue: $0) } }
        selectedRow = nil
        selectedCol = nil
        invalidCells = []
        isComplete = false
    }

    func nextPuzzle()     { if hasNextPuzzle     { loadPuzzle(at: currentPuzzleIndex + 1) } }
    func previousPuzzle() { if hasPreviousPuzzle { loadPuzzle(at: currentPuzzleIndex - 1) } }

    func requestNextPuzzle() {
        guard hasNextPuzzle else { return }
        if hasUserEntries {
            showNextPuzzleConfirmation = true
        } else {
            nextPuzzle()
        }
    }

    // MARK: - Cell interaction

    func selectCell(row: Int, col: Int) {
        if selectedRow == row, selectedCol == col {
            selectedRow = nil; selectedCol = nil
        } else {
            selectedRow = row; selectedCol = col
        }
    }

    /// Enter a digit. Tapping the same digit a second time erases it (toggle).
    func enterNumber(_ number: Int) {
        guard let row = selectedRow, let col = selectedCol else { return }
        guard !cells[row][col].isGiven else { return }
        invalidCells = []
        cells[row][col].userValue = (cells[row][col].userValue == number) ? 0 : number
        checkCompletion()
    }

    func eraseSelected() {
        guard let row = selectedRow, let col = selectedCol else { return }
        guard !cells[row][col].isGiven else { return }
        cells[row][col].userValue = 0
        invalidCells = []
    }

    // MARK: - Validation

    /// Highlights incorrect user-entered cells in red without revealing answers.
    func validate() {
        guard let puzzle = currentPuzzle else { return }
        invalidCells = []
        for row in 0..<9 {
            for col in 0..<9 {
                let cell = cells[row][col]
                if !cell.isGiven, cell.userValue != 0,
                   cell.userValue != puzzle.solution[row][col] {
                    invalidCells.insert(key(row, col))
                }
            }
        }
    }

    private func checkCompletion() {
        guard let puzzle = currentPuzzle else { return }
        for row in 0..<9 {
            for col in 0..<9 {
                if cells[row][col].displayValue != puzzle.solution[row][col] { return }
            }
        }
        isComplete = true
        showCongratulations = true
        recordCompletion()
    }

    // MARK: - Completion persistence

    private func loadCompletionRecords() {
        guard let data = UserDefaults.standard.data(forKey: "completionRecords"),
              let records = try? JSONDecoder().decode([CompletionRecord].self, from: data)
        else { return }
        completionRecords = records
    }

    private func saveCompletionRecords() {
        guard let data = try? JSONEncoder().encode(completionRecords) else { return }
        UserDefaults.standard.set(data, forKey: "completionRecords")
    }

    private func recordCompletion() {
        guard let puzzle = currentPuzzle,
              !isCompleted(puzzleId: puzzle.id) else { return }
        completionRecords.append(
            CompletionRecord(puzzleId: puzzle.id,
                             difficulty: puzzle.difficulty,
                             completedAt: Date())
        )
        saveCompletionRecords()
    }

    // MARK: - Highlight helpers for the grid

    func isSelected(row: Int, col: Int) -> Bool {
        selectedRow == row && selectedCol == col
    }

    /// True if the cell shares a row, column, or 3×3 box with the selected cell.
    func isHighlighted(row: Int, col: Int) -> Bool {
        guard let sr = selectedRow, let sc = selectedCol else { return false }
        return row == sr || col == sc || (row / 3 == sr / 3 && col / 3 == sc / 3)
    }

    /// True if the cell has the same non-zero digit as the selected cell.
    func isSameNumber(row: Int, col: Int) -> Bool {
        guard let sr = selectedRow, let sc = selectedCol else { return false }
        let selected = cells[sr][sc].displayValue
        guard selected != 0 else { return false }
        return cells[row][col].displayValue == selected && !(row == sr && col == sc)
    }

    func isInvalid(row: Int, col: Int) -> Bool {
        invalidCells.contains(key(row, col))
    }

    // MARK: - Private utilities

    private func key(_ row: Int, _ col: Int) -> String { "\(row),\(col)" }

    private static func emptyGrid() -> [[CellData]] {
        Array(repeating: Array(repeating: CellData(givenValue: 0), count: 9), count: 9)
    }
}
