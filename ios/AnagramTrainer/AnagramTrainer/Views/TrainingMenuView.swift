import SwiftUI

struct TrainingMenuView: View {
    @ObservedObject var viewModel: GameViewModel

    private let trainingModes: [TrainingMode] = [
        .graduated, .suffix, .prefix,
        .vowelCluster, .consonantBlend, .digraph, .trigraph
    ]

    private func icon(for mode: TrainingMode) -> String {
        switch mode {
        case .random: return "shuffle"
        case .graduated: return "chart.bar"
        case .suffix: return "arrow.right.to.line"
        case .prefix: return "arrow.left.to.line"
        case .digraph: return "2.circle"
        case .vowelCluster: return "a.circle"
        case .consonantBlend: return "b.circle"
        case .trigraph: return "3.circle"
        }
    }

    private func color(for mode: TrainingMode) -> Color {
        switch mode {
        case .random: return .cyan
        case .graduated: return .green
        case .suffix: return .orange
        case .prefix: return .blue
        case .digraph: return .purple
        case .vowelCluster: return .pink
        case .consonantBlend: return .teal
        case .trigraph: return .indigo
        }
    }

    private var isLargeDevice: Bool {
        UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac
    }


    var body: some View {
        ZStack {
            MenuBackgroundView(
                gridSize: 10,
                gap: isLargeDevice ? 50.0 : 10.0,
                scale: 1.0,
                fontSize: 8.0,
                rotationDuration: 30.0
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(trainingModes) { mode in
                        if mode == .graduated {
                            NavigationLink(destination: GraduatedDifficultySelector(viewModel: viewModel)) {
                                MenuButton(
                                    title: mode.rawValue,
                                    icon: icon(for: mode),
                                    color: color(for: mode)
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
                            NavigationLink(destination: GamePlayView(viewModel: viewModel, mode: mode)) {
                                MenuButton(
                                    title: mode.rawValue,
                                    icon: icon(for: mode),
                                    color: color(for: mode)
                                )
                            }
                            .buttonStyle(.plain)
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
}

#Preview {
    NavigationStack {
        TrainingMenuView(viewModel: GameViewModel())
    }
}
