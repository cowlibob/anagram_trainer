import SwiftUI

struct TrainingMenuView: View {
    @ObservedObject var viewModel: GameViewModel

    private let trainingModes: [TrainingMode] = [
        .graduated, .suffix, .prefix,
        .vowelCluster, .consonantBlend, .digraph, .trigraph
    ]

    @Environment(\.scalingFactor) var scalingFactor
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        ZStack {
            MenuBackgroundView(
                gridSize: 10,
                gap: 10.0 * scalingFactor,
                scale: 1.0,
                fontSize: 8.0,
                rotationDuration: 30.0
            )
            .ignoresSafeArea()

            ScrollView {
                Group {
                    if horizontalSizeClass == .regular {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            trainingButtons
                        }
                    } else {
                        VStack(spacing: 20) {
                            trainingButtons
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
    }

    @ViewBuilder
    private var trainingButtons: some View {
        ForEach(trainingModes) { mode in
            if mode == .graduated {
                NavigationLink(destination: GraduatedDifficultySelector(viewModel: viewModel)) {
                    MenuButton(
                        title: mode.rawValue,
                        icon: mode.icon,
                        color: mode.color
                    )
                }
                .buttonStyle(.plain)
            } else {
                NavigationLink(destination: GamePlayView(viewModel: viewModel, mode: mode)) {
                    MenuButton(
                        title: mode.rawValue,
                        icon: mode.icon,
                        color: mode.color
                    )
                }
                .buttonStyle(.plain)
            }
        }

        Button(action: {
            GameCenterManager.shared.showLeaderboard()
        }) {
            MenuButton(
                title: "Leaderboards",
                icon: "trophy.fill",
                color: .orange
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        TrainingMenuView(viewModel: GameViewModel())
    }
}
