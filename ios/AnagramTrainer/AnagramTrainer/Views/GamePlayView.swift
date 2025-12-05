import SwiftUI
import Combine

struct GamePlayView: View {
    @ObservedObject var viewModel: GameViewModel
    let mode: TrainingMode
    @Environment(\.dismiss) private var dismiss
    @State private var showingResult = false
    @State private var showHint = false
    @State private var hintActivationTime: Date?
    
    private func resetHintTimer() {
        // Only hide hint when truly resetting (new word)
        hintActivationTime = Date()
    }
    
    private func resetHintForNewWord() {
        showHint = false
        hintActivationTime = Date()
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 5) {
                Text(mode.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                
                if mode == .graduated {
                    Text("Level \(viewModel.currentLevel)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else if !mode.hints.isEmpty {
                    Text("Patterns: \(mode.hints)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)
            
            if let state = viewModel.gameState {
                // Scrambled word display
                ScrambledWordView(
                    scrambled: state.scrambledWord,
                    currentGuess: state.currentGuess,
                    usedPositions: state.usedPositions,
                    mode: mode,
                    targetWord: state.targetWord,
                    showHint: showHint,
                    onLetterAction: { originalIndex, letter in
                        if state.usedPositions.contains(originalIndex) {
                            // If already used, remove it (toggle off)
                            viewModel.addLetter(at: originalIndex, letter: letter) // togglePosition handles removal if present
                        } else {
                            // If not used, add it (toggle on)
                            viewModel.addLetter(at: originalIndex, letter: letter)
                        }
                        resetHintTimer()
                    }
                )
                .padding(.horizontal)
                
                // Current guess with cursor
                VStack {
                    GuessView(
                        guess: state.currentGuess,
                        cursorPosition: state.cursorPosition,
                        isSolved: state.isSolved,
                        onTapPosition: { position in
                            viewModel.setCursor(at: position)
                        }
                    )
                    .frame(height: 60)
                }
                .onChange(of: state.currentGuess) { _ in
                    resetHintTimer()
                }
                .onChange(of: state.scrambledWord) { _ in
                    // Reset hint completely when new word loads
                    resetHintForNewWord()
                }
                .onReceive(Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()) { _ in
                    // Check if 15 seconds have passed since last interaction
                    // Don't show hint if all letters are used (guess is complete)
                    let allLettersUsed = state.currentGuess.count == state.scrambledWord.count
                    
                    if let activationTime = hintActivationTime,
                       Date().timeIntervalSince(activationTime) >= 15.0,
                       !state.currentGuess.isEmpty || state.usedPositions.isEmpty,
                       !allLettersUsed {
                        showHint = true
                    } else if allLettersUsed {
                        showHint = false
                    }
                }
                .onAppear {
                    resetHintForNewWord()
                }
                
                // Timer
                TimerView(startTime: state.startTime, endTime: state.endTime)
                
                Spacer()
                
                // Result display
                if state.isComplete {
                    GameResultView(
                        word: state.targetWord,
                        solved: state.isSolved,
                        time: state.elapsedTime,
                        definition: viewModel.definition,
                        onNext: {
                            viewModel.resetForNextWord()
                            viewModel.startNewRound(mode: mode)
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
                            if viewModel.gameState?.isComplete ?? false {
                                Task {
                                    await viewModel.fetchDefinition()
                                }
                            }
                        }) {
                            Label("Submit", systemImage: "checkmark.circle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.gradient)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(state.currentGuess.isEmpty)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        viewModel.skipWord()
                    }) {
                        Text("Give Up / Skip")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(.bottom)
                }
            } else {
                ProgressView()
                    .onAppear {
                        viewModel.startNewRound(mode: mode)
                    }
            }
        }
        .navigationTitle(mode.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Reset if mode changed, no game state, or level changed in graduated mode
            let levelChanged = mode == .graduated && 
                               viewModel.gameState != nil && 
                               viewModel.gameState!.targetWord.count != viewModel.currentLevel
            
            if viewModel.currentMode != mode || viewModel.gameState == nil || levelChanged {
                viewModel.startNewRound(mode: mode)
            }
        }
    }
}

#Preview {
    NavigationStack {
        GamePlayView(viewModel: GameViewModel(), mode: .random)
    }
}
