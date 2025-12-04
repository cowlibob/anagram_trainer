import SwiftUI

struct CampaignGameView: View {
    @ObservedObject var viewModel: CampaignViewModel
    let state: GameState
    
    var body: some View {
        VStack(spacing: 30) {
            // Scrambled word
            ScrambledWordView(
                scrambled: state.scrambledWord,
                currentGuess: state.currentGuess,
                usedPositions: state.usedPositions,
                mode: .random, // Campaign doesn't show hints
                targetWord: state.targetWord,
                showHint: false,
                onLetterAction: { originalIndex, letter in
                    viewModel.addLetter(at: originalIndex, letter: letter) // togglePosition handles both add/remove
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
            TimerView(startTime: state.startTime, endTime: state.endTime)
            
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
