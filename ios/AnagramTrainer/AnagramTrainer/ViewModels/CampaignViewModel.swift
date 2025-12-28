import Foundation
import Combine
import UIKit

/// ViewModel for campaign mode logic
class CampaignViewModel: ObservableObject {
    @Published var currentStageIndex: Int = 0
    @Published var totalScore: Int = 0
    @Published var wordsRemaining: Int = 0
    @Published var lastRoundPoints: Int = 0
    @Published var isComplete: Bool = false
    @Published var gameState: GameState?
    
    // Track session history
    @Published var currentHistory: [WordAttempt] = []

    private let dictionary = Dictionary.shared
    private let persistence = PersistenceManager.shared
    
    var currentStage: CampaignStage {
        guard currentStageIndex < CampaignStage.allStages.count else {
            return CampaignStage.allStages.last!
        }
        return CampaignStage.allStages[currentStageIndex]
    }
    
    var progressText: String {
        "Stage \(currentStageIndex + 1)/\(CampaignStage.allStages.count): \(currentStage.name)"
    }
    
    init() {
        loadProgress()
        setupLifecycleObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupLifecycleObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appDidEnterBackground() {
        gameState?.pauseTimer()
    }
    
    @objc private func appWillEnterForeground() {
        gameState?.resumeTimer()
    }
    
    // MARK: - Campaign Flow
    
    func startNewCampaign() {
        currentStageIndex = 0
        totalScore = 0
        isComplete = false
        resetStageProgress()
        currentHistory = []
        persistence.clearCampaignProgress()
        startNextWord()
    }
    
    func resumeCampaign() {
        startNextWord()
    }
    
    func resetCampaign() {
        currentStageIndex = 0
        totalScore = 0
        lastRoundPoints = 0
        isComplete = false
        gameState = nil
        persistence.clearCampaignProgress()
    }
    
    func pauseGame() {
        gameState?.pauseTimer()
    }
    
    func resumeGame() {
        gameState?.resumeTimer()
    }
    
    // MARK: - Debug Helpers
    
    #if DEBUG
    func skipToLastWord() {
        // Jump to last stage
        currentStageIndex = CampaignStage.allStages.count - 1
        // Set to last word of that stage
        wordsRemaining = 1
        // Add some score for testing
        totalScore = 3500
        startNextWord()
    }
    #endif
    
    func startNextWord() {
        guard currentStageIndex < CampaignStage.allStages.count else {
            completeCampaign()
            return
        }
        
        let stage = currentStage
        let mode = stage.mode
        let minLength = stage.length ?? 5
        let maxLength = stage.length
        
        guard let word = dictionary.randomWord(
            mode: mode,
            minLength: minLength,
            maxLength: maxLength
        ) else {
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
        
        
        if isValid {
            recordSuccess(timeToken: state.elapsedTime)
        } else {
            state.attempts += 1
            gameState = state
        }
    }
    
    func skipWord() {
        // Record attempt info FIRST
        if let target = gameState?.targetWord {
            currentHistory.append(WordAttempt(
                word: target.uppercased(),
                duration: gameState?.elapsedTime ?? 0,
                outcome: .skipped
            ))
        }
        
        // Mark as complete
        gameState?.completeGame(solved: false)
        lastRoundPoints = 0
        
        // Advance game state immediately (consistent with recordSuccess)
        wordsRemaining -= 1
        checkStageCompletion()
        saveProgress()
    }
    
    // Deprecated: Logic moved to skipWord for consistency. 
    // Kept empty or removed to prevent double-counting if view calls it.
    func recordSkip() {
        // No-op: handled in skipWord
    }
    
    private func recordSuccess(timeToken: TimeInterval) {
        // Mark as complete to show result screen
        if var state = gameState {
            state.completeGame(solved: true, winningWord: state.currentGuess)
            gameState = state
        }
        
        // Scoring: Base 100 + time bonus (max 150)
        let baseScore = 100
        let timeBonus = max(0, Int((15.0 - timeToken) * 10))
        let points = baseScore + timeBonus
        
        totalScore += points
        lastRoundPoints = points
        wordsRemaining -= 1
        
        // Record attempt info
        if let target = gameState?.targetWord {
            let isExact = gameState?.currentGuess.uppercased() == target.uppercased()
            currentHistory.append(WordAttempt(
                word: target.uppercased(),
                duration: timeToken,
                outcome: isExact ? .exact : .correct
            ))
        }
        
        checkStageCompletion()
        saveProgress()
    }
    
    private func checkStageCompletion() {
        if wordsRemaining <= 0 {
            advanceStage()
        }
    }
    
    private func advanceStage() {
        currentStageIndex += 1
        
        if currentStageIndex >= CampaignStage.allStages.count {
            completeCampaign()
        } else {
            resetStageProgress()
        }
    }
    
    private func resetStageProgress() {
        wordsRemaining = currentStage.count
    }
    
    private func completeCampaign() {
        isComplete = true
        persistence.clearCampaignProgress()
    }
    
    func resetForNextWord() {
        gameState = nil
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
    
    // MARK: - Persistence
    
    func saveProgress() {
        persistence.saveCampaignProgress(
            stage: currentStageIndex,
            score: totalScore,
            wordsRemaining: wordsRemaining
        )
    }
    
    func loadProgress() {
        if let progress = persistence.loadCampaignProgress() {
            currentStageIndex = progress.stage
            totalScore = progress.score
            wordsRemaining = progress.wordsRemaining
        } else {
            resetStageProgress()
        }
    }
    
    func hasSavedProgress() -> Bool {
        persistence.loadCampaignProgress() != nil
    }
    
    // MARK: - Leaderboard
    
    func submitToLeaderboard(playerName: String) {
        // Submit to local for backup if desired
        let entry = LeaderboardEntry(
            playerName: playerName, 
            score: totalScore, 
            history: currentHistory
        )
        persistence.addLeaderboardEntry(entry)
        
        // Submit to Game Center
        GameCenterManager.shared.submitScore(totalScore)
    }
}
