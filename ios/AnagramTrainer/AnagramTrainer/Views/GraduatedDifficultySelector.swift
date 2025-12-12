import SwiftUI

struct GraduatedDifficultySelector: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    
    let levels = Array(5...9)

    private var isLargeDevice: Bool {
        UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac
    }

    private func color(for count: Int) -> Color {
        switch count {
        case 5: return .cyan
        case 6: return .green
        case 7: return .orange
        case 8: return .blue
        case 9: return .purple
        default: return .clear
        }
    }

    var body: some View {
        ZStack {
            MenuBackgroundView(scale: 1.0)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.3, blue: 0.5),  // Vibrant pink
                            Color(red: 0.95, green: 0.4, blue: 0.6),  // Soft pink
                            Color(red: 0.8, green: 0.3, blue: 0.7)    // Purple-pink
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundStyle(Color.white)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                VStack(spacing: 10) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)

                Text("Graduated Difficulty")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("Select word length")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.top, 50)
            
            Spacer()
            
            VStack(spacing: isLargeDevice ? 15 : 12) {
                ForEach(levels, id: \.self) { level in
                    NavigationLink(destination: GamePlayView(viewModel: viewModel, mode: .graduated)) {
                        MenuButton(
                            title: "\(level) Letters",
                            icon: nil,
                            color: color(for: level),
                            showCurrent: level == viewModel.currentLevel
                        )
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(TapGesture().onEnded {
                        viewModel.currentLevel = level
                        viewModel.streak = 0
                    })
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()

            Text("Solve 3 words in a row to advance")
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
                .padding(.bottom, 30)
        }
        }
        .navigationTitle("Select Difficulty")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
    }
}

#Preview {
    NavigationStack {
        GraduatedDifficultySelector(viewModel: GameViewModel())
    }
}
