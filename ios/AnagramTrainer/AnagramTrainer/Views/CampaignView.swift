import SwiftUI

struct CampaignView: View {
    @ObservedObject var viewModel: CampaignViewModel
    @State private var showingLeaderboardEntry = false
    @State private var playerName = ""
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
                CampaignCompleteView(
                    score: viewModel.totalScore,
                    onSubmit: { name in
                        viewModel.submitToLeaderboard(playerName: name)
                        showingLeaderboardEntry = false
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

struct CampaignGameView: View {
    @ObservedObject var viewModel: CampaignViewModel
    let state: GameState
    
    var body: some View {
        VStack(spacing: 30) {
            // Scrambled word
            ScrambledWordView(
                scrambled: state.scrambledWord,
                usedPositions: state.usedPositions,
                onLetterTap: { position, letter in
                    viewModel.addLetter(at: position, letter: letter)
                }
            )
            .padding(.horizontal)
            
            // Current guess with cursor
            GuessView(
                guess: state.currentGuess,
                cursorPosition: state.cursorPosition,
                isSolved: state.isSolved,
                onTapPosition: { position in
                    viewModel.setCursor(at: position)
                }
            )
            .frame(height: 60)
            
            // Timer
            TimerView(startTime: state.startTime)
            
            Spacer()
            
            // Result or actions
            if state.isComplete {
                CampaignResultView(
                    word: state.targetWord,
                    solved: state.isSolved,
                    points: viewModel.lastRoundPoints,
                    onNext: {
                        if !state.isSolved {
                            viewModel.recordSkip()
                        }
                        viewModel.resetForNextWord()
                        viewModel.startNextWord()
                    }
                )
            } else {
                // Action buttons
                HStack(spacing: 20) {
                    Button(action: {
                        viewModel.clearGuess()
                    }) {
                        Label("Clear", systemImage: "xmark.circle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        viewModel.submitGuess()
                    }) {
                        Label("Submit", systemImage: "checkmark.circle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.gradient)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(state.currentGuess.isEmpty)
                }
                .padding(.horizontal)
                
                Button(action: {
                    viewModel.skipWord()
                }) {
                    Text("Skip (No Points)")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.bottom)
            }
        }
    }
}

struct CampaignResultView: View {
    let word: String
    let solved: Bool
    let points: Int
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: solved ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(solved ? .green : .red)
            
            Text(solved ? "Correct!" : "Skipped")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(word.uppercased())
                .font(.title)
                .foregroundColor(.blue)
            
            if solved {
                Text("+\(points) points")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            Button(action: onNext) {
                Text("Next Word")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.gradient)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
        }
    }
}

struct CampaignCompleteView: View {
    let score: Int
    let onSubmit: (String) -> Void
    @State private var playerName = ""
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundStyle(.yellow.gradient)
            
            Text("Campaign Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Final Score: \(score)")
                .font(.title)
                .foregroundColor(.blue)
            
            VStack(spacing: 15) {
                Text("Enter your name for the leaderboard:")
                    .font(.headline)
                
                TextField("Player Name", text: $playerName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 40)
                
                Button(action: {
                    if !playerName.isEmpty {
                        onSubmit(playerName)
                    }
                }) {
                    Text("Submit Score")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.gradient)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                .disabled(playerName.isEmpty)
            }
        }
        .padding()
    }
}

struct LeaderboardEntrySheet: View {
    let score: Int
    let isPartial: Bool
    let onSubmit: (String) -> Void
    @State private var playerName = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Image(systemName: isPartial ? "exclamationmark.triangle" : "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(isPartial ? Color.orange.gradient : Color.yellow.gradient)
                
                Text(isPartial ? "Campaign Ended Early" : "Campaign Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Score: \(score)")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(spacing: 15) {
                    Text("Enter your name for the leaderboard:")
                        .font(.headline)
                    
                    TextField("Player Name", text: $playerName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    Button(action: {
                        if !playerName.isEmpty {
                            onSubmit(playerName)
                            dismiss()
                        }
                    }) {
                        Text("Submit Score")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.gradient)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    .disabled(playerName.isEmpty)
                }
            }
            .padding()
            .navigationTitle("Submit Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CampaignView(viewModel: CampaignViewModel())
    }
}
