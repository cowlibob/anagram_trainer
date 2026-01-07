import SwiftUI

struct PauseMenuView: View {
    let history: [WordAttempt]
    let quitTitle: String
    let onResume: () -> Void
    let onQuit: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scalingFactor) var scalingFactor
    @ObservedObject var userSettings = UserSettings.shared
    
    var body: some View {
        GeometryReader { geometry in
            let isShort = geometry.size.height < 600

            ZStack {
                // Darkened background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onResume()
                    }

                VStack {
                    Spacer()

                    VStack(spacing: isShort ? 12 : 24) {
                        // Header
                        Text("PAUSED")
                            .font(.custom("DIN Condensed", size: (isShort ? 32 : 48) * scalingFactor))
                            .kerning(4)
                            .foregroundColor(.primary)

                        // Content Card
                        VStack(spacing: 0) {
                            if history.isEmpty {
                                VStack(spacing: 15) {
                                    Image(systemName: "pencil.and.list.clipboard")
                                        .font(.system(size: isShort ? 30 : 40))
                                        .foregroundColor(.secondary)

                                    Text("No words solved yet")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, isShort ? 20 : 40)
                            } else {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Words So Far")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal)
                                        .padding(.top, 15)

                                    List {
                                        ForEach(history.reversed()) { attempt in
                                            HStack(spacing: 15) {
                                                // Outcome Icon
                                                Group {
                                                    switch attempt.outcome {
                                                    case .exact:
                                                        Image(systemName: "star.circle.fill")
                                                            .foregroundColor(.yellow)
                                                    case .correct:
                                                        Image(systemName: "checkmark.circle.fill")
                                                            .foregroundColor(.green)
                                                    case .skipped:
                                                        Image(systemName: "arrow.right.circle.fill")
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                                .font(.title2)
                                                .frame(width: 30)

                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text((attempt.guessedWord ?? attempt.word).uppercased())
                                                        .font(.headline)
                                                        .foregroundColor(.primary)

                                                    Text(outcomeText(attempt.outcome))
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                }

                                                Spacer()

                                                if attempt.outcome != .skipped {
                                                    Text(String(format: "%.1fs", attempt.duration))
                                                        .font(.system(.body, design: .monospaced))
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            .listRowBackground(Color.primary.opacity(0.03))
                                            .listRowSeparator(.hidden)
                                        }
                                    }
                                    .listStyle(.plain)
                                    .scrollContentBackground(.hidden)
                                }
                            }
                        }
                        .frame(maxWidth: 500, maxHeight: isShort ? 200 : 300)
                        .background(Color.primary.opacity(0.03))
                        .cornerRadius(12)

                        // Handedness Setting
                        VStack(spacing: 8) {
                            Text("Handedness")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Picker("Handedness", selection: $userSettings.handedness) {
                                ForEach(Handedness.allCases) { hand in
                                    Text(hand.rawValue).tag(hand)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.horizontal)

                        // Action Buttons
                        VStack(spacing: isShort ? 10 : 15) {
                            Button(action: onResume) {
                                HStack {
                                    Image(systemName: "play.fill")
                                    Text("Resume")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 12)
                                .background(Color.green)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(.plain)

                            Button(action: onQuit) {
                                HStack {
                                    Image(systemName: "xmark")
                                    Text(quitTitle)
                                }
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 12)
                                .background(Color.primary.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(isShort ? 20 : 40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    )
                    .padding(.horizontal, isShort ? 20 : 40)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .transition(.opacity)
            .zIndex(100) // Ensure it sits on top
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

#Preview {
    PauseMenuView(
        history: [
            WordAttempt(word: "TEST", duration: 2.5, outcome: .correct),
            WordAttempt(word: "SKIP", duration: 1.0, outcome: .skipped),
            WordAttempt(word: "PERFECT", duration: 5.0, outcome: .exact)
        ],
        quitTitle: "Quit Game",
        onResume: {},
        onQuit: {}
    )
}
