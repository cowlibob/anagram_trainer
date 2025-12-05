import SwiftUI

struct CampaignView: View {
    @ObservedObject var viewModel: CampaignViewModel
    @State private var showingLeaderboardEntry = false
    @State private var playerName = ""
    @State private var navigateToLeaderboard = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            if !viewModel.isComplete {
                // Campaign header
                VStack(spacing: 10) {
                    Text(viewModel.progressText)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Score display
                    HStack(spacing: 30) {
                        VStack {
                            Text("Score")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(viewModel.totalScore)")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        
                        VStack {
                            Text("Words Left")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(viewModel.wordsRemaining)")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        
                        if viewModel.lastRoundPoints > 0 {
                            VStack {
                                Text("Last Round")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("+\(viewModel.lastRoundPoints)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                }
                .padding()
                
                // Stage info
                if !viewModel.currentStage.mode.hints.isEmpty {
                    Text("Patterns: \(viewModel.currentStage.mode.hints)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                #if DEBUG
                // Debug button to skip to last word
                Button(action: {
                    viewModel.skipToLastWord()
                }) {
                    Text("🐛 Skip to Last Word")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple)
                        .cornerRadius(8)
                }
                .padding(.bottom, 5)
                #endif
                
                // Game play
                if let state = viewModel.gameState {
                    CampaignGameView(
                        viewModel: viewModel,
                        state: state
                    )
                } else {
                    ProgressView()
                        .onAppear {
                            if viewModel.hasSavedProgress() {
                                // Show resume dialog
                            } else {
                                viewModel.startNewCampaign()
                            }
                        }
                }
            } else {
                // Campaign complete
                NavigationLink(
                    destination: LeaderboardDismissWrapper(
                        onDismiss: {
                            // First dismiss the leaderboard, then dismiss the campaign
                            navigateToLeaderboard = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                dismiss()
                            }
                        }
                    ),
                    isActive: $navigateToLeaderboard
                ) {
                    EmptyView()
                }
                .hidden()
                
                CampaignCompleteView(
                    score: viewModel.totalScore,
                    onSubmit: { name in
                        viewModel.submitToLeaderboard(playerName: name)
                        navigateToLeaderboard = true
                    }
                )
            }
        }
        .navigationTitle("Train Me Campaign")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !viewModel.isComplete {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Quit") {
                        showingLeaderboardEntry = true
                    }
                }
            }
        }
        .sheet(isPresented: $showingLeaderboardEntry) {
            LeaderboardEntrySheet(
                score: viewModel.totalScore,
                isPartial: !viewModel.isComplete,
                onSubmit: { name in
                    viewModel.submitToLeaderboard(playerName: name)
                    viewModel.resetCampaign()
                    showingLeaderboardEntry = false
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    NavigationStack {
        CampaignView(viewModel: CampaignViewModel())
    }
}
