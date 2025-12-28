import SwiftUI

struct CampaignGameView: View {
    @ObservedObject var viewModel: CampaignViewModel
    let state: GameState
    @FocusState private var isFocused: Bool
    @State private var keyboardInput: String = ""
    @State private var showingResult = false
    @Environment(\.scalingFactor) var scalingFactor

    private var isLargeDevice: Bool {
        UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac
    }

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

        GeometryReader { geometry in
            let isShort = geometry.size.height < 600
            
            VStack(spacing: isShort ? 10 : (isLargeDevice ? 30 : 20)) {
                // Inline header for short mode
                if isShort {
                    HStack {
                        HStack(spacing: 4) {
                            Text("Score:")
                                .foregroundColor(.white.opacity(0.6))
                            Text("\(viewModel.totalScore)")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        
                        Spacer()
                        
                        TimerView(
                            startTime: state.startTime,
                            endTime: state.endTime,
                            totalPausedDuration: state.totalPausedDuration,
                            isPaused: state.pausedTime != nil
                        )
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("Left:")
                                .foregroundColor(.white.opacity(0.6))
                            Text("\(viewModel.wordsRemaining)")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }

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
                .frame(height: isShort ? 40 : 60)

                if !isShort {
                    // Timer
                    TimerView(
                        startTime: state.startTime,
                        endTime: state.endTime,
                        totalPausedDuration: state.totalPausedDuration,
                        isPaused: state.pausedTime != nil
                    )
                }

                Spacer()

                // Concentric Experimental UI
                if !state.isComplete {
                    ConcentricCircularButtons(
                        onSubmit: { viewModel.submitGuess() },
                        onClear: { viewModel.clearGuess() },
                        onSkip: { viewModel.skipWord() },
                        isSubmitDisabled: state.currentGuess.isEmpty
                    )
                    .zIndex(5)
                }
            }
        }
        }
        .focusable()
        .focused($isFocused)
        .fullScreenCover(isPresented: $showingResult) {
            CampaignResultView(
                word: state.winningWord ?? state.targetWord,
                solved: state.isSolved,
                points: viewModel.lastRoundPoints,
                onNext: {
                    showingResult = false
                    viewModel.resetForNextWord()
                    viewModel.startNextWord()
                }
            )
            .presentationBackground(.clear)
        }
        .onChange(of: state.isComplete) {
            if state.isComplete {
                showingResult = true
            }
        }
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
