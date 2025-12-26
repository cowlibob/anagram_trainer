import SwiftUI

struct CampaignView: View {
    @ObservedObject var viewModel: CampaignViewModel
    @State private var showingLeaderboardEntry = false
    @State private var playerName = ""
    @State private var navigateToLeaderboard = false
    @Environment(\.dismiss) private var dismiss

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

            VStack(spacing: 20) {
                if !viewModel.isComplete {
                // Campaign header
                VStack(spacing: 10) {
                    Text(viewModel.progressText)
                        .font(isLargeDevice ? .title2 : .headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    // Score display
                    HStack(spacing: 30) {
                        VStack {
                            Text("Score")
                                .font(isLargeDevice ? .caption : .caption2)
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(viewModel.totalScore)")
                                .font(isLargeDevice ? .title : .title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }

                        VStack {
                            Text("Words Left")
                                .font(isLargeDevice ? .caption : .caption2)
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(viewModel.wordsRemaining)")
                                .font(isLargeDevice ? .title : .title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }

                        if viewModel.lastRoundPoints > 0 {
                            VStack {
                                Text("Last Round")
                                    .font(isLargeDevice ? .caption : .caption2)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("+\(viewModel.lastRoundPoints)")
                                    .font(isLargeDevice ? .title3 : .headline)
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
                        .font(isLargeDevice ? .caption : .caption2)
                        .foregroundColor(.white.opacity(0.9))
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
                                viewModel.resumeCampaign()
                            } else {
                                viewModel.startNewCampaign()
                            }
                        }
                }
            } else {
                CampaignCompleteView(
                    score: viewModel.totalScore,
                    onSubmit: { name in
                        viewModel.submitToLeaderboard(playerName: name)
                        // Show Game Center leaderboard
                        GameCenterManager.shared.showLeaderboard()
                        // Dismiss campaign view
                        dismiss()
                    }
                )
            }
        }
        }
        .navigationTitle("Train Me Campaign")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
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
            .onDisappear {
                // Reset campaign if sheet was dismissed without submitting
                if showingLeaderboardEntry {
                    viewModel.resetCampaign()
                }
            }
        }
        .onAppear {
            // If returning to campaign after completion, start fresh
            if viewModel.isComplete {
                viewModel.startNewCampaign()
            }
        }
    }
}

#Preview {
    NavigationStack {
        CampaignView(viewModel: CampaignViewModel())
    }
}
