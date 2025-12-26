import SwiftUI

struct GameResultView: View {
    let word: String
    let solved: Bool
    let time: TimeInterval
    let definition: String
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 24) {
                Image(systemName: solved ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(solved ? .green : .orange)

                Text(solved ? "Correct!" : "The word was:")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.black)

                Text(word.uppercased())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(solved ? .green : Color(red: 1.0, green: 0.3, blue: 0.5))

                if solved {
                    Text(String(format: "Time: %.1fs", time))
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                VStack {
                    if definition.isEmpty {
                        VStack(spacing: 12) {
                            ProgressView()
                                .tint(.secondary)
                            Text("Fetching definition...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ScrollView {
                            Text(definition)
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                }
                .frame(height: 150) // Fixed height to prevent button jitter
                .background(Color.primary.opacity(0.03))
                .cornerRadius(12)
                .padding(.horizontal)

                Button(action: onNext) {
                    MenuButton(title: "Next Word", icon: "arrow.right.circle", color: .blue)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(40)
    }
}
