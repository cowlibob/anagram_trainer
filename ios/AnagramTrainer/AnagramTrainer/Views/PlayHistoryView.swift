import SwiftUI

struct PlayHistoryView: View {
    let entry: LeaderboardEntry
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scalingFactor) var scalingFactor

    private let standardLight = Color.green
    private let standardDark = Color(red: 0.063, green: 0.235, blue: 0.106)

    var body: some View {
        ZStack {
            SpriteMenuBackgroundView(
               gridSize: 6,
               fontSize: 120.0,
               rotationDuration: 180.0
            )
             .environment(\.themeBaseColor, .green)
             .environment(\.themeDarkBaseColor, standardDark)
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with player info
                VStack(spacing: 8) {
                    Text(entry.playerName.uppercased())
                        .font(.custom("DIN Condensed", size: 32 * scalingFactor))
                        .foregroundColor(.white)

                    HStack(spacing: 20) {
                        HStack(spacing: 5) {
                            Image(systemName: "star.fill")
                            Text("\(entry.score)")
                        }
                        HStack(spacing: 5) {
                            Image(systemName: "calendar")
                            Text(entry.formattedDate)
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                }
                .padding(.vertical, 20)

                ScrollView {
                    VStack(spacing: 12) {
                        if let history = entry.history, !history.isEmpty {
                            ForEach(history) { attempt in
                                historyRow(attempt)
                            }
                        } else {
                            Text("No detailed history available for this entry.")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.top, 50)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("PLAY SESSION")
                    .font(.custom("DIN Condensed", size: 28 * scalingFactor))
                    .kerning(2)
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
    }

    @ViewBuilder
    private func historyRow(_ attempt: WordAttempt) -> some View {
        HStack(spacing: 15) {
            // Outcome Icon
            outcomeIcon(attempt.outcome)
                .font(.title2)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(attempt.word)
                        .font(.custom("DIN Condensed", size: 22 * scalingFactor))
                        .foregroundColor(.white)

                    if let guessed = attempt.guessedWord, guessed != attempt.word {
                        Text("(\(guessed))")
                            .font(.custom("DIN Condensed", size: 18 * scalingFactor))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Text(outcomeText(attempt.outcome))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if attempt.outcome != .skipped {
                    Text("\(attempt.points) pts")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.green.opacity(0.9))

                    Text(String(format: "%.1fs", attempt.duration))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Text("0 pts")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    @ViewBuilder
    private func outcomeIcon(_ outcome: WordOutcome) -> some View {
        switch outcome {
        case .correct:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .exact:
            Image(systemName: "star.circle.fill")
                .foregroundColor(.yellow)
        case .skipped:
            Image(systemName: "arrow.right.circle.fill")
                .foregroundColor(.gray)
        }
    }

    private func outcomeText(_ outcome: WordOutcome) -> String {
        switch outcome {
        case .correct: return "Solved"
        case .exact: return "Exact Match"
        case .skipped: return "Skipped"
        }
    }
}
