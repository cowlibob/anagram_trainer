import SwiftUI
import Combine

struct GamePlayView: View {
    @ObservedObject var viewModel: GameViewModel
    let mode: TrainingMode
    @Environment(\.dismiss) private var dismiss
    @State private var showingResult = false
    @State private var showHint = false
    @State private var hintActivationTime: Date?
    @FocusState private var isFocused: Bool
    @State private var keyboardInput: String = ""
    
    private func resetHintTimer() {
        // Only hide hint when truly resetting (new word)
        hintActivationTime = Date()
    }
    
    private func resetHintForNewWord() {
        showHint = false
        hintActivationTime = Date()
    }

    private func handleKeyPress(_ key: String) {
        guard let state = viewModel.gameState, !state.isComplete else { return }

        let uppercaseKey = key.uppercased()

        // Handle letter input
        if uppercaseKey.count == 1, uppercaseKey.first?.isLetter == true {
            // Find first unused occurrence of this letter
            for (index, letter) in state.scrambledWord.enumerated() {
                if String(letter).uppercased() == uppercaseKey && !state.usedPositions.contains(index) {
                    viewModel.addLetter(at: index, letter: letter)
                    resetHintTimer()
                    break
                }
            }
        }
    }

    private func handleBackspace() {
        guard let state = viewModel.gameState, !state.isComplete else { return }

        // Remove last letter from guess
        if !state.currentGuess.isEmpty {
            // Find the last used position and toggle it off
            if let lastUsedIndex = state.usedPositions.sorted().last {
                let letter = state.scrambledWord[state.scrambledWord.index(state.scrambledWord.startIndex, offsetBy: lastUsedIndex)]
                viewModel.addLetter(at: lastUsedIndex, letter: letter)
                resetHintTimer()
            }
        }
    }

    var body: some View {
        ZStack {
            MenuBackgroundView(
                gridSize: 5,
                gap: 25.0,
                scale: 0.5,
                fontSize: 10.0,
                rotationDuration: 300.0
            )
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.3, blue: 0.5),  // Vibrant pink
                            Color(red: 0.95, green: 0.4, blue: 0.6),  // Soft pink
                            Color(red: 0.8, green: 0.3, blue: 0.7)    // Purple-pink
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundStyle(Color.white)
                .ignoresSafeArea()

            // Hidden TextField for keyboard input capture
            TextField("", text: $keyboardInput)
                .frame(width: 0, height: 0)
                .opacity(0)
                .focused($isFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onChange(of: keyboardInput) { newValue in
                    if let lastChar = newValue.last {
                        if lastChar.isLetter {
                            handleKeyPress(String(lastChar))
                        }
                    }
                    // Clear the field to allow repeated characters
                    DispatchQueue.main.async {
                        keyboardInput = ""
                    }
                }

            VStack(spacing: 30) {
//                // Header
                VStack(spacing: 5) {
//                Text(mode.rawValue)
//                    .font(.title2)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)

                if mode == .graduated {
                    Text("Level \(viewModel.currentLevel)")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                } else if !mode.hints.isEmpty {
                    Text("Patterns: \(mode.hints)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
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
                        word: state.isSolved ? state.currentGuess : state.targetWord,
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
        }
        .focusable()
        .focused($isFocused)
        .navigationTitle(mode.rawValue)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
        .onKeyPress { press in
            if press.key == .delete || press.key == .deleteForward {
                handleBackspace()
                return .handled
            } else if press.key == .leftArrow {
                if let state = viewModel.gameState, state.cursorPosition > 0 {
                    viewModel.setCursor(at: state.cursorPosition - 1)
                }
                return .handled
            } else if press.key == .rightArrow {
                if let state = viewModel.gameState, state.cursorPosition < state.currentGuess.count {
                    viewModel.setCursor(at: state.cursorPosition + 1)
                }
                return .handled
            } else if press.key == .return {
                if let state = viewModel.gameState, !state.currentGuess.isEmpty && !state.isComplete {
                    viewModel.submitGuess()
                    if viewModel.gameState?.isComplete ?? false {
                        Task {
                            await viewModel.fetchDefinition()
                        }
                    }
                    return .handled
                }
            } else if let character = press.characters.first, character.isLetter {
                handleKeyPress(String(character))
                return .handled
            }
            return .ignored
        }
        .onAppear {
            // Reset if mode changed, no game state, or level changed in graduated mode
            let levelChanged = mode == .graduated &&
                               viewModel.gameState != nil &&
                               viewModel.gameState!.targetWord.count != viewModel.currentLevel

            if viewModel.currentMode != mode || viewModel.gameState == nil || levelChanged {
                viewModel.startNewRound(mode: mode)
            }

            // Set focus for keyboard input
            isFocused = true
        }
    }
}

#Preview {
    NavigationStack {
        GamePlayView(viewModel: GameViewModel(), mode: .random)
    }
}
