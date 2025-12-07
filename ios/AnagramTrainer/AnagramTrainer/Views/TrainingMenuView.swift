import SwiftUI

struct TrainingMenuView: View {
    @ObservedObject var viewModel: GameViewModel
    
    private let trainingModes: [TrainingMode] = [
        .graduated, .suffix, .prefix, .digraph, 
        .vowelCluster, .consonantBlend, .trigraph
    ]
    
    var body: some View {
        ZStack {
            MenuBackgroundView(
                gridSize: 10,
                gap: 50.0,
                scale: 1.0,
                fontSize: 8.0,
                rotationDuration: 30.0
            )
            List(trainingModes) { mode in
            if mode == .graduated {
                NavigationLink(destination: GraduatedDifficultySelector(viewModel: viewModel)) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(mode.rawValue)
                                .font(.headline)
                                .foregroundColor(.white)

                            Spacer()
                            Text("Level \(viewModel.currentLevel)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }

                        Text(mode.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.vertical, 4)
                }
            } else {
                NavigationLink(destination: GamePlayView(viewModel: viewModel, mode: mode)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(mode.rawValue)
                            .font(.headline)
                            .foregroundColor(.white)

                        Text(mode.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))

                        if !mode.hints.isEmpty {
                            Text(mode.hints)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Training Modes")
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
        }
    }
}

#Preview {
    NavigationStack {
        TrainingMenuView(viewModel: GameViewModel())
    }
}
