import SwiftUI

struct TrainingMenuView: View {
    @ObservedObject var viewModel: GameViewModel
    
    private let trainingModes: [TrainingMode] = [
        .graduated, .suffix, .prefix, .digraph, 
        .vowelCluster, .consonantBlend, .trigraph
    ]
    
    var body: some View {
        List(trainingModes) { mode in
            if mode == .graduated {
                NavigationLink(destination: GraduatedDifficultySelector(viewModel: viewModel)) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(mode.rawValue)
                                .font(.headline)
                            
                            Spacer()
                            Text("Level \(viewModel.currentLevel)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                        
                        Text(mode.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            } else {
                NavigationLink(destination: GamePlayView(viewModel: viewModel, mode: mode)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(mode.rawValue)
                            .font(.headline)
                        
                        Text(mode.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if !mode.hints.isEmpty {
                            Text(mode.hints)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Training Modes")
    }
}

#Preview {
    NavigationStack {
        TrainingMenuView(viewModel: GameViewModel())
    }
}
