import SwiftUI

struct GraduatedDifficultySelector: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scalingFactor) var scalingFactor
    
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

            GeometryReader { geometry in
                let isShort = geometry.size.height < 600
                
                ScrollView {
                    VStack(spacing: isShort ? 15 : 30) {
                        VStack(spacing: isShort ? 4 : 10) {
                            if !isShort {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.system(size: 60 * scalingFactor))
                                    .foregroundStyle(.white)
                                    .padding(.bottom, 10)
                            }

                            Text("Graduated Difficulty")
                                .font(isShort ? .title3 : .largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("Select word length")
                                .font(isShort ? .caption : .title3)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .padding(.top, isShort ? 10 : 50)
                        
                        if isShort {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(levels, id: \.self) { level in
                                    difficultyButton(level: level, isCompact: true)
                                }
                            }
                            .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: isLargeDevice ? 15 : 12) {
                                ForEach(levels, id: \.self) { level in
                                    difficultyButton(level: level, isCompact: false)
                                }
                            }
                            .padding(.horizontal, 40)
                        }
                        
                        Text("Solve 3 words in a row to advance")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.top, isShort ? 5 : 10)
                            .padding(.bottom, isShort ? 20 : 30)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, isShort ? 10 : 0)
                }
            }
        }
        .navigationTitle("Select Difficulty")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
    }

    @ViewBuilder
    private func difficultyButton(level: Int, isCompact: Bool) -> some View {
        NavigationLink(destination: GamePlayView(viewModel: viewModel, mode: .graduated)) {
            MenuButton(
                title: "\(level) Letters",
                icon: nil,
                color: color(for: level),
                showCurrent: level == viewModel.currentLevel,
                isCompact: isCompact    
            )
        }
        .buttonStyle(.plain)
        .simultaneousGesture(TapGesture().onEnded {
            viewModel.currentLevel = level
            viewModel.streak = 0
        })
    }
}

#Preview {
    NavigationStack {
        GraduatedDifficultySelector(viewModel: GameViewModel())
    }
}
