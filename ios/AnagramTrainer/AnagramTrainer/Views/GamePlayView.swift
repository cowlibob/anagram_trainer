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
    @State private var showPauseMenu = false
    @State private var wasBackgrounded = false
    @Environment(\.scalingFactor) var scalingFactor
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var speechManager = SpeechRecognitionManager()
    
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

            // Debug logging removed

            // Use helper to find which scrambled position to remove
            if let positionToRemove = KeyboardInputHelper.getPositionToRemove(
                cursorPosition: state.cursorPosition,
                guess: state.currentGuess,
                scrambledWord: state.scrambledWord,
                usedPositions: state.usedPositions
            ) {
                let letterAtScrambledPos = state.scrambledWord[state.scrambledWord.index(state.scrambledWord.startIndex, offsetBy: positionToRemove)]

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
            ThemeManager.shared.backgroundGradient(for: colorScheme == .dark ? mode.darkColor : mode.color, colorScheme: colorScheme)
                .ignoresSafeArea()

             SpriteMenuBackgroundView(
                gridSize: 6,
                fontSize: 120.0,
                rotationDuration: 180.0
             )
//            MenuBackgroundView(
//                gridSize: 5,
//                gap: -10.0,
//                scale: 0.5,
//                fontSize: 10.0,
//                rotationDuration: 300.0,
//                opacity: 0.05
//            )
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
                                    // Left-aligned Timer (swapped position)
                                    HStack(alignment: .center) {
                                        if let state = viewModel.gameState {
                                            TimerView(
                                                startTime: state.startTime,
                                                endTime: state.endTime,
                                                totalPausedDuration: state.totalPausedDuration,
                                                isPaused: state.pausedTime != nil
                                            )
                                        }
                                        Spacer()

                                        // Right-aligned Pause Button
                                        Button(action: {
                                            viewModel.pauseGame()
                                            showPauseMenu = true
                                        }) {
                                            Image(systemName: "pause")
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundColor(.white.opacity(0.4))
                                        }
                                    }
                                    
                                    // Centered Timer
                                    if let state = viewModel.gameState {
                                        TimerView(
                                            startTime: state.startTime,
                                            endTime: state.endTime,
                                            totalPausedDuration: state.totalPausedDuration,
                                            isPaused: state.pausedTime != nil
                                        )
                                    }
                                }
                                .padding(.top, 10)
                            } else {
                                HStack(alignment: .center) {
                                    if let state = viewModel.gameState {
                                        TimerView(
                                            startTime: state.startTime,
                                            endTime: state.endTime,
                                            totalPausedDuration: state.totalPausedDuration,
                                            isPaused: state.pausedTime != nil
                                        )
                                    }

                                    Spacer()

                                    // Right-aligned Pause Button
                                    Button(action: {
                                        viewModel.pauseGame()
                                        showPauseMenu = true
                                    }) {
                                        Image(systemName: "pause")
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white.opacity(0.4))
                                    }
                                }
                                .padding(.top, 40 * scalingFactor)
                            }
                        }
                        .padding(.horizontal, 20 * scalingFactor)

                        Spacer()
                            .frame(height: isShort ? 5 : 20)

                        if let state = viewModel.gameState {
                            // Current guess with cursor and mic button - moved above letter buttons
                            HStack(spacing: 16) {
                                Spacer()
                                
                                GuessView(
                                    guess: state.currentGuess,
                                    cursorPosition: state.cursorPosition,
                                    isSolved: state.isSolved,
                                    onTapPosition: { position in
                                        viewModel.setCursor(at: position)
                                    }
                                )
                                .frame(height: isShort ? 44 : 60)
                                
                                Spacer()
                                
                                // Microphone button
                                Button(action: {
                                    if !speechManager.isAuthorized {
                                        speechManager.requestAuthorization()
                                    }
                                    
                                    // Provide context to improve accuracy (target words + letters)
                                    let context = viewModel.getSpeechContext()
                                    speechManager.toggleListening(contextualStrings: context)
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(speechManager.isListening ? Color.red : Color.white.opacity(0.2))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: speechManager.isListening ? "mic.fill" : "mic")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                    .scaleEffect(speechManager.isListening ? 1.1 : 1.0)
                                    .animation(speechManager.isListening ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .easeInOut(duration: 0.2), value: speechManager.isListening)
                                }
                                .padding(.trailing, 20)
                            }
                            
                            // Scrambled word display - moved below guessed word
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
                            .onAppear {
                                // Request authorization on first appear
                                speechManager.requestAuthorization()
                                
                                // Connect speech recognition to input handling
                                speechManager.onTextRecognized = { text in
                                    Task { @MainActor in
                                        for char in text {
                                            self.handleKeyPress(String(char))
                                        }
                                    }
                                }
                            }
                            .onChange(of: state.currentGuess) {
                                resetHintTimer()
                            }
                            .onChange(of: state.scrambledWord) {
                                // Reset hint completely when new word loads
                                resetHintForNewWord()
                                // Stop listening on new word
                                if speechManager.isListening {
                                    speechManager.stopListening()
                                }
                            }
                            .onChange(of: state.isComplete) {
                                // Stop listening when game is complete (answer submitted or skipped)
                                if state.isComplete && speechManager.isListening {
                                    speechManager.stopListening()
                                }
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
            .navigationBarBackButtonHidden(true)
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
                        viewModel.setCursor(at: newPos)
                    }
                    return .handled
                } else if press.key == .rightArrow {
                    if let state = viewModel.gameState, state.cursorPosition < state.currentGuess.count {
                        let newPos = state.cursorPosition + 1
                        let leftPart = String(state.currentGuess.prefix(newPos))
                            let rightPart = String(state.currentGuess.suffix(state.currentGuess.count - newPos))
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
                // Reset if mode changed, no game state, level changed in graduated mode, or game is complete
                let levelChanged = mode == .graduated &&
                viewModel.gameState != nil &&
                viewModel.gameState!.targetWord.count != viewModel.currentLevel

                let gameIsComplete = viewModel.gameState?.isComplete == true

                if viewModel.currentMode != mode || viewModel.gameState == nil || levelChanged || gameIsComplete {
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
                .zIndex(10)
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
            
            // Pause Menu Overlay
            if showPauseMenu {
                PauseMenuView(
                    history: viewModel.sessionHistory,
                    quitTitle: "Quit training",
                    onResume: {
                        viewModel.resumeGame()
                        showPauseMenu = false
                    },
                    onQuit: {
                        showPauseMenu = false
                        dismiss()
                    }
                )
                .zIndex(10)
            }
            
            // Concentric Experimental UI - Moved to outer ZStack for correct corner anchoring
            if let state = viewModel.gameState, !state.isComplete {
                ConcentricCircularButtons(
                    onSubmit: { viewModel.submitGuess() },
                    onClear: { viewModel.clearGuess() },
                    onSkip: { viewModel.skipWord() },
                    isSubmitDisabled: state.currentGuess.isEmpty
                )
                .zIndex(5)
            }
        }
        .onAppear {
            // mode.color is handled by the environment/gradient caller
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            // Pause when app becomes inactive or goes to background
            if newPhase == .inactive || newPhase == .background {
                if !showPauseMenu && viewModel.gameState?.isComplete == false {
                    viewModel.pauseGame()
                    wasBackgrounded = true
                }
            }
            // Show pause menu when returning to active after backgrounding
            else if newPhase == .active {
                if wasBackgrounded && !showPauseMenu && viewModel.gameState?.isComplete == false {
                    showPauseMenu = true
                    wasBackgrounded = false
                }
            }
        }
        .environment(\.themeBaseColor, colorScheme == .dark ? mode.darkColor : mode.color)
        .environment(\.themeDarkBaseColor, mode.darkColor)
    }

}

#Preview {
    NavigationStack {
        GamePlayView(viewModel: GameViewModel(), mode: .random)
    }
}
