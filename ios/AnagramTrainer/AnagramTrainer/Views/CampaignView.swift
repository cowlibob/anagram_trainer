import SwiftUI

struct CampaignView: View {
    @ObservedObject var viewModel: CampaignViewModel
    @State private var showingLeaderboardEntry = false
    @State private var playerName = ""
    @State private var navigateToLeaderboard = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scalingFactor) var scalingFactor

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

            GeometryReader { geometry in
                let isShort = geometry.size.height < 600
                
                VStack(spacing: isShort ? 5 : 20) {
                    if !viewModel.isComplete {
                        // Standing header (only in non-short mode)
                        if !isShort {
                            VStack(spacing: 10) {
                                Text(viewModel.progressText)
                                    .font(isLargeDevice ? .title2 : .headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)

                                // Score display
                                HStack(spacing: 30) {
                                    scoreColumn(title: "Score", value: "\(viewModel.totalScore)", isShort: false)
                                    scoreColumn(title: "Words Left", value: "\(viewModel.wordsRemaining)", isShort: false)

                                    if viewModel.lastRoundPoints > 0 {
                                        scoreColumn(title: "Last Round", value: "+\(viewModel.lastRoundPoints)", color: .green, isShort: false)
                                    }
                                }
                                .padding(15)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)

                            // Stage info
                            if !viewModel.currentStage.mode.hints.isEmpty {
                                Text("Patterns: \(viewModel.currentStage.mode.hints)")
                                    .font(.caption2)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        
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
        }
        .navigationTitle("Test")
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
    @ViewBuilder
    private func scoreColumn(title: String, value: String, color: Color = .white, isShort: Bool) -> some View {
        VStack(spacing: isShort ? 0 : 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            Text(value)
                .font(isShort ? .headline : .title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

#Preview {
    NavigationStack {
        CampaignView(viewModel: CampaignViewModel())
    }
}
