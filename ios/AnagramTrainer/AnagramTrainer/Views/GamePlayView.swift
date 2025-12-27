import SwiftUI
import Combine

struct GamePlayView: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var theme = ThemeManager.shared
    let mode: TrainingMode
    @Environment(\.dismiss) private var dismiss
    @State private var showingResult = false
    @State private var showHint = false
    @State private var hintActivationTime: Date?
    @FocusState private var isFocused: Bool
    @State private var keyboardInput: String = ""
    @State private var showingModeInfo = false
    @Environment(\.scalingFactor) var scalingFactor
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme
    
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

        // Remove letter to the left of cursor
        if !state.currentGuess.isEmpty && state.cursorPosition > 0 {
            // Debug logging
            let leftPart = String(state.currentGuess.prefix(state.cursorPosition))
            let rightPart = String(state.currentGuess.suffix(state.currentGuess.count - state.cursorPosition))
            let charToRemove = String(state.currentGuess[state.currentGuess.index(state.currentGuess.startIndex, offsetBy: state.cursorPosition - 1)])

            print("🔙 BACKSPACE - Guess: '\(state.currentGuess)' | Scrambled: '\(state.scrambledWord)'")
            print("   Left: '\(leftPart)' | Right: '\(rightPart)' | CursorPos: \(state.cursorPosition)")
            print("   Char to remove: '\(charToRemove)' at guess index \(state.cursorPosition - 1)")

            // Use helper to find which scrambled position to remove
            if let positionToRemove = KeyboardInputHelper.getPositionToRemove(
                cursorPosition: state.cursorPosition,
                guess: state.currentGuess,
                scrambledWord: state.scrambledWord,
                usedPositions: state.usedPositions
            ) {
                let letterAtScrambledPos = state.scrambledWord[state.scrambledWord.index(state.scrambledWord.startIndex, offsetBy: positionToRemove)]
                print("   Removing scrambled position \(positionToRemove) which has letter '\(letterAtScrambledPos)'")

                let newCursorPosition = state.cursorPosition - 1
                viewModel.addLetter(at: positionToRemove, letter: letterAtScrambledPos)

                // Move cursor left after state updates
                DispatchQueue.main.async {
                    viewModel.setCursor(at: newCursorPosition)
                }
                resetHintTimer()
            }
        }
    }

    var body: some View {
        ZStack {
            // Root background gradient to "seal" any potential gaps
            ThemeManager.shared.backgroundGradient(for: mode.color, colorScheme: colorScheme)
                .ignoresSafeArea()

            MenuBackgroundView(
                gridSize: 5,
                gap: -10.0,
                scale: 0.5,
                fontSize: 10.0,
                rotationDuration: 300.0,
                opacity: 0.05
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

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
                
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: isShort ? 20 * scalingFactor : 40 * scalingFactor) {
                        // Header
                        Group {
                            if isShort {
                                ZStack {
                                    // Left-aligned Pause/Rules button
                                    HStack {
                                        Button(action: {
                                            viewModel.pauseGame()
                                            showingModeInfo = true
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "pause.fill")
                                                    .font(.system(size: 12))
                                                Text("Rules")
                                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                            }
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.white.opacity(0.1))
                                            .cornerRadius(8)
                                        }
                                        Spacer()
                                    }
                                    
                                    // Centered Timer
                                    if let state = viewModel.gameState {
                                        TimerView(startTime: state.startTime, endTime: state.endTime, isPaused: state.pausedTime != nil)
                                    }
                                }
                                .padding(.top, 10)
                            } else {
                                VStack(spacing: 8) {
                                    Button(action: {
                                        viewModel.pauseGame()
                                        showingModeInfo = true
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "pause.circle.fill")
                                            Text("Pause & Rules")
                                                .fontWeight(.bold)
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(20)
                                    }

                                    if let state = viewModel.gameState {
                                        TimerView(startTime: state.startTime, endTime: state.endTime, isPaused: state.pausedTime != nil)
                                    }
                                }
                                .padding(.top, 40 * scalingFactor)
                            }
                        }
                        .padding(.horizontal, 20 * scalingFactor)

                        Spacer()
                            .frame(height: isShort ? 5 : 20)

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
                            .padding(.horizontal, 20 * scalingFactor)
                            
                            // Current guess with cursor
                            VStack {
                                GuessView(
                                    guess: state.currentGuess,
                                    cursorPosition: state.cursorPosition,
                                    isSolved: state.isSolved,
                                    onTapPosition: { position in
                                        let leftPart = String(state.currentGuess.prefix(position))
                                        let rightPart = String(state.currentGuess.suffix(state.currentGuess.count - position))
                                        print("👆 CURSOR TAP - Moving to \(position) | Left: '\(leftPart)' | Right: '\(rightPart)'")
                                        viewModel.setCursor(at: position)
                                    }
                                )
                                .frame(height: isShort ? 44 : 60)
                            }
                            .onChange(of: state.currentGuess) {
                                resetHintTimer()
                            }
                            .onChange(of: state.scrambledWord) {
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

                            Spacer()
                                .frame(minHeight: isShort ? 5 : 40)

                            // Action buttons
                            if !state.isComplete {
                                VStack(spacing: isShort ? 12 : 16) {
                                    // Row for main actions
                                    Group {
                                        if isShort {
                                            HStack(spacing: 8) {
                                                submitButton(state: state, isCompact: true, showIcon: false)
                                                clearButton(isCompact: true, showIcon: false)
                                                skipButton(isCompact: true, showIcon: false)
                                            }
                                        } else {
                                            VStack(spacing: 16) {
                                                submitButton(state: state, isCompact: false, showIcon: true)
                                                clearButton(isCompact: false, showIcon: true)
                                                
                                                Button(action: {
                                                    viewModel.skipWord()
                                                }) {
                                                    Text("Give Up / Skip")
                                                        .font(.caption)
                                                        .foregroundColor(.white.opacity(0.7))
                                                }
                                                .padding(.top, 4)
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, isShort ? 10 * scalingFactor : 20 * scalingFactor)
                                .padding(.bottom, isShort ? 20 * scalingFactor : 40 * scalingFactor)
                            }
                        } else {
                            ProgressView()
                                .onAppear {
                                    viewModel.startNewRound(mode: mode)
                                }
                        }
                    }
                }
            }
            .focusable()
            .focused($isFocused)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .tint(.white)
            .onKeyPress { press in
                if press.key == .delete || press.key == .deleteForward {
                    handleBackspace()
                    return .handled
                } else if press.key == .leftArrow {
                    if let state = viewModel.gameState, state.cursorPosition > 0 {
                        let newPos = state.cursorPosition - 1
                        let leftPart = String(state.currentGuess.prefix(newPos))
                        let rightPart = String(state.currentGuess.suffix(state.currentGuess.count - newPos))
                        print("⬅️ CURSOR LEFT - Moving to \(newPos) | Left: '\(leftPart)' | Right: '\(rightPart)'")
                        viewModel.setCursor(at: newPos)
                    }
                    return .handled
                } else if press.key == .rightArrow {
                    if let state = viewModel.gameState, state.cursorPosition < state.currentGuess.count {
                        let newPos = state.cursorPosition + 1
                        let leftPart = String(state.currentGuess.prefix(newPos))
                            let rightPart = String(state.currentGuess.suffix(state.currentGuess.count - newPos))
                        print("➡️ CURSOR RIGHT - Moving to \(newPos) | Left: '\(leftPart)' | Right: '\(rightPart)'")
                        viewModel.setCursor(at: newPos)
                    }
                    return .handled
                } else if press.key == .return {
                    if let state = viewModel.gameState, !state.currentGuess.isEmpty && !state.isComplete {
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
                // Reset if mode changed, no game state, or level changed in graduated mode
                let levelChanged = mode == .graduated &&
                viewModel.gameState != nil &&
                viewModel.gameState!.targetWord.count != viewModel.currentLevel
                
                if viewModel.currentMode != mode || viewModel.gameState == nil || levelChanged {
                    viewModel.startNewRound(mode: mode)
                    
                    // Show info popup for specific training modes on entry
                    if mode != .random && mode != .graduated {
                        showingModeInfo = true
                    }
                }
                
                // Set focus for keyboard input
                isFocused = true
            }

            // Mode Info Overlay
            if showingModeInfo {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            viewModel.resumeGame()
                            showingModeInfo = false
                        }
                    
                    ModeInfoView(
                        mode: mode,
                        buttonTitle: "Continue",
                        onDismiss: {
                            viewModel.resumeGame()
                            showingModeInfo = false
                        }
                    )
                }
                .transition(.opacity.combined(with: .scale))
                .zIndex(2)
            }

            // Result overlay - at outer ZStack level
            if let state = viewModel.gameState, state.isComplete {
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
            }
        }
        .onAppear {
            // mode.color is handled by the environment/gradient caller
        }
        .environment(\.themeBaseColor, mode.color)
        .environment(\.themeDarkBaseColor, mode.color)
    }

    @ViewBuilder
    private func submitButton(state: GameState, isCompact: Bool, showIcon: Bool) -> some View {
        Button(action: {
            viewModel.submitGuess()
        }) {
            MenuButton(title: "Submit", icon: showIcon ? "checkmark.circle" : nil, color: .blue, isCompact: isCompact, textColor: .white)
        }
        .disabled(state.currentGuess.isEmpty)
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func clearButton(isCompact: Bool, showIcon: Bool) -> some View {
        Button(action: {
            viewModel.clearGuess()
        }) {
            MenuButton(title: "Clear", icon: showIcon ? "xmark.circle" : nil, color: .gray, isCompact: isCompact, textColor: .white)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func skipButton(isCompact: Bool, showIcon: Bool) -> some View {
        HoldToConfirmButton(
            title: "Skip",
            icon: showIcon ? "arrow.right.circle" : nil,
            color: .red.opacity(0.8),
            isCompact: isCompact,
            action: { viewModel.skipWord() }
        )
    }
}

#Preview {
    NavigationStack {
        GamePlayView(viewModel: GameViewModel(), mode: .random)
    }
}
