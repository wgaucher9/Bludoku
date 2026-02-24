import Foundation

// MARK: - Puzzle data loaded from JSON

struct SudokuPuzzle: Codable, Identifiable {
    let id: Int
    let difficulty: String
    let puzzle: [[Int]]
    let solution: [[Int]]
}

struct PuzzleCollection: Codable {
    let puzzles: [SudokuPuzzle]
}

// MARK: - Completion tracking

struct CompletionRecord: Codable, Identifiable {
    let puzzleId: Int
    let difficulty: String
    let completedAt: Date
    var id: Int { puzzleId }
}

// MARK: - Live cell state during gameplay

struct CellData {
    /// Non-zero if this is a pre-filled clue cell.
    let givenValue: Int
    /// Player-entered value; only meaningful when !isGiven.
    var userValue: Int

    var isGiven: Bool    { givenValue != 0 }
    var displayValue: Int { isGiven ? givenValue : userValue }
    var isEmpty: Bool     { displayValue == 0 }

    init(givenValue: Int) {
        self.givenValue = givenValue
        self.userValue  = 0
    }
}
