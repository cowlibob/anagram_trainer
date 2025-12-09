import SwiftUI

struct CampaignGameView: View {
    @ObservedObject var viewModel: CampaignViewModel
    let state: GameState
    @FocusState private var isFocused: Bool
    @State private var keyboardInput: String = ""

    private func handleKeyPress(_ key: String) {
        guard !state.isComplete else { return }

        let uppercaseKey = key.uppercased()

        // Handle letter input
        if uppercaseKey.count == 1, uppercaseKey.first?.isLetter == true {
            // Find first unused occurrence of this letter
            for (index, letter) in state.scrambledWord.enumerated() {
                if String(letter).uppercased() == uppercaseKey && !state.usedPositions.contains(index) {
                    viewModel.addLetter(at: index, letter: letter)
                    break
                }
            }
        }
    }

    private func handleBackspace() {
        guard !state.isComplete else { return }

        // Remove letter to the left of cursor
        if !state.currentGuess.isEmpty && state.cursorPosition > 0 {
            // Use helper to find which scrambled position to remove
            if let positionToRemove = KeyboardInputHelper.getPositionToRemove(
                cursorPosition: state.cursorPosition,
                guess: state.currentGuess,
                scrambledWord: state.scrambledWord,
                usedPositions: state.usedPositions
            ) {
                let letter = state.scrambledWord[state.scrambledWord.index(state.scrambledWord.startIndex, offsetBy: positionToRemove)]
                let newCursorPosition = state.cursorPosition - 1

                viewModel.addLetter(at: positionToRemove, letter: letter)

                // Move cursor left after state updates
                DispatchQueue.main.async {
                    viewModel.setCursor(at: newCursorPosition)
                }
            }
        }
    }

    var body: some View {
        ZStack {
            // Hidden TextField for keyboard input capture
            TextField("", text: $keyboardInput)
                .frame(width: 0, height: 0)
                .opacity(0)
                .focused($isFocused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .onChange(of: keyboardInput) {
                    if let lastChar = keyboardInput.last {
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

            // Action buttons
            if !state.isComplete {
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

        // Result overlay
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
        }
        }
        .focusable()
        .focused($isFocused)
        .onKeyPress { press in
            if press.key == .delete || press.key == .deleteForward {
                handleBackspace()
                return .handled
            } else if press.key == .leftArrow {
                if state.cursorPosition > 0 {
                    viewModel.setCursor(at: state.cursorPosition - 1)
                }
                return .handled
            } else if press.key == .rightArrow {
                if state.cursorPosition < state.currentGuess.count {
                    viewModel.setCursor(at: state.cursorPosition + 1)
                }
                return .handled
            } else if press.key == .return {
                if !state.currentGuess.isEmpty && !state.isComplete {
                    viewModel.submitGuess()
                    return .handled
                }
            } else if let character = press.characters.first, character.isLetter {
                handleKeyPress(String(character))
                return .handled
            }
            return .ignored
        }
        .onAppear {
            isFocused = true
        }
    }
}
