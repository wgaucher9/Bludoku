import SwiftUI

struct StatsView: View {
    let records: [CompletionRecord]
    let puzzleCount: Int

    @Environment(\.dismiss) private var dismiss

    private var sortedRecords: [CompletionRecord] {
        records.sorted { $0.completedAt > $1.completedAt }
    }

    private var countsByDifficulty: [(difficulty: String, count: Int)] {
        let grouped = Dictionary(grouping: records, by: \.difficulty)
        return ["easy", "medium", "hard"].compactMap { diff in
            guard let count = grouped[diff]?.count, count > 0 else { return nil }
            return (difficulty: diff, count: count)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // Summary
                Section("Summary") {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("\(records.count) of \(puzzleCount) solved")
                    }
                    ForEach(countsByDifficulty, id: \.difficulty) { item in
                        HStack {
                            DifficultyBadge(difficulty: item.difficulty)
                            Spacer()
                            Text("\(item.count)")
                                .foregroundColor(.secondary)
                                .monospacedDigit()
                        }
                    }
                }

                // History
                if !sortedRecords.isEmpty {
                    Section("History") {
                        ForEach(sortedRecords) { record in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Puzzle \(record.puzzleId)")
                                        .font(.headline)
                                    Text(record.completedAt.formatted(
                                        date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                DifficultyBadge(difficulty: record.difficulty)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
