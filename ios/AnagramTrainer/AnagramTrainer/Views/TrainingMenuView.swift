import SwiftUI

struct TrainingMenuView: View {
    @ObservedObject var viewModel: GameViewModel
    
    private let trainingModes: [TrainingMode] = [
        .graduated, .suffix, .prefix, .digraph, 
        .vowelCluster, .consonantBlend, .trigraph
    ]
    
    var body: some View {
        List(trainingModes) { mode in
            NavigationLink(destination: GamePlayView(viewModel: viewModel, mode: mode)) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(mode.rawValue)
                            .font(.headline)
                        
                        if mode == .graduated {
                            Spacer()
                            Text("Level \(viewModel.currentLevel)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                    
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
        .navigationTitle("Training Modes")
    }
}

#Preview {
    NavigationStack {
        TrainingMenuView(viewModel: GameViewModel())
    }
}
