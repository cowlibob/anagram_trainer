import SwiftUI

struct CampaignResultView: View {
    let word: String
    let solved: Bool
    let points: Int
    let onNext: () -> Void

    var body: some View {
        ZStack {
            // Transparent background to see through
            Color.clear
                .background(.ultraThinMaterial.opacity(0.5))
                .ignoresSafeArea()

            // White card overlay
            VStack(spacing: 24) {
                Image(systemName: solved ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(solved ? .green : .orange)

                Text(solved ? "Correct!" : "Skipped")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(word.uppercased())
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 1.0, green: 0.3, blue: 0.5))

                if solved {
                    Text("+\(points) points")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }

                Button(action: onNext) {
                    MenuButton(title: "Next Word", icon: "arrow.right.circle", color: .orange)
                }
                .buttonStyle(.plain)
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
