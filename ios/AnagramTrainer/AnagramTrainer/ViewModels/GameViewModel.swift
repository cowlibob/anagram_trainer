import Foundation
import Combine

/// ViewModel for game logic and state management
class GameViewModel: ObservableObject {
    @Published var gameState: GameState?
    @Published var currentMode: TrainingMode = .random
    @Published var currentLevel: Int = 5
    @Published var streak: Int = 0
    @Published var showingDefinition: Bool = false
    @Published var definition: String = ""
    
    private let dictionary = Dictionary.shared
    private let persistence = PersistenceManager.shared
    
    init() {
        currentLevel = persistence.loadLevel()
    }
    
    // MARK: - Game Flow
    
    func startNewRound(mode: TrainingMode) {
        currentMode = mode
        
        guard let word = dictionary.randomWord(
            mode: mode,
            minLength: currentLevel,
            maxLength: mode == .graduated ? currentLevel : nil
        ) else {
            print("ERROR: Could not find word for mode \(mode)")
            return
        }
        
        let scrambled = dictionary.scramble(word)
        gameState = GameState(targetWord: word, scrambledWord: scrambled)
    }
    
    func submitGuess() {
        guard var state = gameState else { return }
        
        // Validate if guess is a valid anagram
        let (isValid, validationTime) = dictionary.isValidAnagram(
            guess: state.currentGuess,
            scrambledLetters: state.scrambledWord
        )
        
        print("[PERFORMANCE] Guess validation took \(String(format: "%.4f", validationTime * 1000))ms")
        
        if isValid {
            handleSuccess()
        } else {
            state.attempts += 1
            gameState = state
        }
    }
    
    func skipWord() {
        gameState?.completeGame()
    }
    
    private func handleSuccess() {
        gameState?.completeGame()
        
        // Handle graduated mode level progression
        if currentMode == .graduated {
            streak += 1
            if streak >= 3 && currentLevel < 9 {
                currentLevel += 1
                streak = 0
                persistence.saveLevel(currentLevel)
            }
        } else {
            streak = 0
        }
    }
    
    func resetForNextWord() {
        gameState = nil
        showingDefinition = false
        definition = ""
    }
    
    // MARK: - Input Handling
    
    func addLetter(at position: Int, letter: Character) {
        guard var state = gameState, !state.isComplete else { return }
        state.togglePosition(position)
        gameState = state
    }
    
    func addLetter(_ letter: Character) {
        guard var state = gameState, !state.isComplete else { return }
        
        // Find first unused position for this letter
        let scrambledArray = Array(state.scrambledWord)
        if let index = scrambledArray.enumerated().first(where: { idx, char in
            char == letter && !state.usedPositions.contains(idx)
        })?.offset {
            state.addLetterAt(position: index, letter: letter)
            gameState = state
        }
    }
    
    func removeLetter(_ letter: Character) {
        guard var state = gameState, !state.isComplete else { return }
        
        // Find last used position for this letter (to remove most recently added)
        // We check positionOrder to find the last added instance of this letter
        let scrambledArray = Array(state.scrambledWord)
        if let positionToRemove = state.positionOrder.last(where: { pos in
            scrambledArray[pos] == letter
        }) {
            state.togglePosition(positionToRemove)
            gameState = state
        }
    }
    
    func removeLetter() {
        guard var state = gameState, !state.isComplete else { return }
        state.removeLetter()
        gameState = state
    }
    
    func clearGuess() {
        guard var state = gameState, !state.isComplete else { return }
        state.clearGuess()
        gameState = state
    }
    
    func setCursor(at position: Int) {
        guard var state = gameState, !state.isComplete else { return }
        state.setCursorPosition(position)
        gameState = state
    }
    
    // MARK: - Definition Fetching
    
    func fetchDefinition() async {
        guard let word = gameState?.targetWord else { return }
        
        let urlString = "https://api.dictionaryapi.dev/api/v2/entries/en/\(word)"
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let first = json.first,
               let meanings = first["meanings"] as? [[String: Any]],
               let firstMeaning = meanings.first,
               let definitions = firstMeaning["definitions"] as? [[String: Any]],
               let firstDef = definitions.first,
               let def = firstDef["definition"] as? String {
                
                await MainActor.run {
                    self.definition = def
                    self.showingDefinition = true
                }
            }
        } catch {
            await MainActor.run {
                self.definition = "Definition not available"
                self.showingDefinition = true
            }
        }
    }
}
