import SwiftUI

struct GameResultView: View {
    let word: String
    let solved: Bool
    let time: TimeInterval
    let definition: String
    let onNext: () -> Void

    var body: some View {
        ZStack {
            // Semi-transparent background overlay
            Color.black.opacity(0.3)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()

            // White card overlay
            VStack(spacing: 24) {
                Image(systemName: solved ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(solved ? .green : .orange)

                Text(solved ? "Correct!" : "The word was:")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                if !solved {
                    Text(word.uppercased())
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.5))
                }

                if solved {
                    Text(String(format: "Time: %.1fs", time))
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                if !definition.isEmpty {
                    ScrollView {
                        Text(definition)
                            .font(.body)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxHeight: 200)
                }

                Button(action: onNext) {
                    Text("Next Word")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.gradient)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            )
            .padding(40)
        }
    }
}
