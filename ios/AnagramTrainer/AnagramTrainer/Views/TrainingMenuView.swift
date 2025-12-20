import SwiftUI

struct TrainingMenuView: View {
    @ObservedObject var viewModel: GameViewModel

    private let trainingModes: [TrainingMode] = [
        .graduated, .suffix, .prefix,
        .vowelCluster, .consonantBlend, .digraph, .trigraph
    ]

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
