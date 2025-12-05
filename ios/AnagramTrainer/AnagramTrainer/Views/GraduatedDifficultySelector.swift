import SwiftUI

struct GraduatedDifficultySelector: View {
    @ObservedObject var viewModel: GameViewModel
    @Environment(\.dismiss) private var dismiss
    
    let levels = Array(5...9)
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 60))
                    .foregroundStyle(.green.gradient)
                
                Text("Graduated Difficulty")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Select word length")
                    .font(.title3)
                    .foregroundColor(.secondary)
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
                .foregroundColor(.secondary)
                .padding(.bottom, 30)
        }
        .navigationTitle("Select Difficulty")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        GraduatedDifficultySelector(viewModel: GameViewModel())
    }
}
