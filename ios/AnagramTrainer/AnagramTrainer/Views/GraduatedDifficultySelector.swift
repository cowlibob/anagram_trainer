import SwiftUI

struct GraduatedDifficultySelector: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    
    let levels = Array(5...9)
    
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
            
            VStack(spacing: 15) {
                ForEach(levels, id: \.self) { level in
                    NavigationLink(destination: GamePlayView(viewModel: viewModel, mode: .graduated)) {
                        HStack {
                            Text("\(level) Letters")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            if level == viewModel.currentLevel {
                                Text("Current")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.gradient)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                    }
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
