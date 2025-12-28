import SwiftUI

struct CampaignView: View {
    @ObservedObject var viewModel: CampaignViewModel
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var showingLeaderboardEntry = false
    @State private var playerName = ""
    @State private var navigateToLeaderboard = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scalingFactor) var scalingFactor

    var onNavigateToLeaderboard: () -> Void = {}
    
    @State private var showPauseMenu = false

    private var isLargeDevice: Bool {
        UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac
    }

    var body: some View {
        ZStack {
            backgroundView
            
            GeometryReader { geometry in
                let isShort = geometry.size.height < 600
                mainContent(isShort: isShort)
            }
        }
        .navigationTitle("Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
        .toolbar {
            if !viewModel.isComplete {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.pauseGame()
                        showPauseMenu = true
                    }) {
                        Image(systemName: "pause.circle")
                            .font(.title2)
                    }
                }
            }
        }
        .overlay {
            if showPauseMenu {
                PauseMenuView(
                    history: viewModel.currentHistory,
                    quitTitle: "Quit Challenge",
                    onResume: {
                        viewModel.resumeGame()
                        showPauseMenu = false
                    },
                    onQuit: {
                        showPauseMenu = false
                        // Reuse existing quit logic
                        if viewModel.totalScore > 0 {
                            showingLeaderboardEntry = true
                        } else {
                            viewModel.resetCampaign()
                            onNavigateToLeaderboard()
                        }
                    }
                )
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
                    onNavigateToLeaderboard() // Also navigate on quit submission
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
        .environment(\.themeBaseColor, Color(red: 1.0, green: 0.6, blue: 0.4))
        .environment(\.themeDarkBaseColor, Color(red: 1.0, green: 0.6, blue: 0.4))
    }

    private var backgroundView: some View {
        MenuBackgroundView(
            gridSize: 10,
            gap: isLargeDevice ? 50.0 : 10.0,
            scale: 1.0,
            fontSize: 8.0,
            rotationDuration: 30.0
        )
        .background(
            ThemeManager.shared.backgroundGradient(
                for: Color(red: 1.0, green: 0.6, blue: 0.4),
                colorScheme: colorScheme
            )
        )
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func mainContent(isShort: Bool) -> some View {
        VStack(spacing: isShort ? 5 : 20) {
            if !viewModel.isComplete {
                if !isShort {
                    campaignHeader(isLargeDevice: isLargeDevice)
                }
                
                campaignGameArea
            } else {
                CampaignCompleteView(
                    score: viewModel.totalScore,
                    onSubmit: { name in
                        viewModel.submitToLeaderboard(playerName: name)
                        viewModel.resetCampaign() // Ensure clean state
                        onNavigateToLeaderboard()
                    }
                )
            }
        }
    }
    
    @ViewBuilder
    private func campaignHeader(isLargeDevice: Bool) -> some View {
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
    
    @ViewBuilder
    private var campaignGameArea: some View {
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
