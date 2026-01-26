import Foundation

/// Centralized persistence using UserDefaults
class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let defaults = UserDefaults.standard
    
    // Keys
    private enum Keys {
        static let currentLevel = "anagram_trainer_level"
        static let campaignStage = "anagram_trainer_campaign_stage"
        static let campaignScore = "anagram_trainer_campaign_score"
        static let campaignWordsRemaining = "anagram_trainer_campaign_words"
        static let leaderboard = "anagram_trainer_leaderboard"
        static let playLeaderboard = "anagram_trainer_play_leaderboard"
        static let graduatedWordCount = "anagram_trainer_graduated_word_count_"
        static let firstWordLength = "anagram_trainer_first_word_length_"
        static let graduatedLevelHistory = "anagram_trainer_graduated_level_history_"
    }
    
    private init() {}
    
    // MARK: - Level Persistence
    
    func saveLevel(_ level: Int) {
        defaults.set(level, forKey: Keys.currentLevel)
    }
    
    func loadLevel() -> Int {
        let level = defaults.integer(forKey: Keys.currentLevel)
        return level > 0 ? level : 5  // Default to 5
    }
    
    // MARK: - Campaign Persistence
    
    func saveCampaignProgress(stage: Int, score: Int, wordsRemaining: Int) {
        defaults.set(stage, forKey: Keys.campaignStage)
        defaults.set(score, forKey: Keys.campaignScore)
        defaults.set(wordsRemaining, forKey: Keys.campaignWordsRemaining)
    }
    
    func loadCampaignProgress() -> (stage: Int, score: Int, wordsRemaining: Int)? {
        guard defaults.object(forKey: Keys.campaignStage) != nil else {
            return nil
        }
        
        let stage = defaults.integer(forKey: Keys.campaignStage)
        let score = defaults.integer(forKey: Keys.campaignScore)
        let wordsRemaining = defaults.integer(forKey: Keys.campaignWordsRemaining)
        
        return (stage, score, wordsRemaining)
    }
    
    func clearCampaignProgress() {
        defaults.removeObject(forKey: Keys.campaignStage)
        defaults.removeObject(forKey: Keys.campaignScore)
        defaults.removeObject(forKey: Keys.campaignWordsRemaining)
    }
    
    // MARK: - Leaderboard Persistence
    
    func saveLeaderboard(_ entries: [LeaderboardEntry]) {
        if let encoded = try? JSONEncoder().encode(entries) {
            defaults.set(encoded, forKey: Keys.leaderboard)
        }
    }
    
    func loadLeaderboard() -> [LeaderboardEntry] {
        guard let data = defaults.data(forKey: Keys.leaderboard),
              let entries = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) else {
            return []
        }
        return entries
    }
    
    func addLeaderboardEntry(_ entry: LeaderboardEntry) {
        var entries = loadLeaderboard()
        entries.append(entry)
        entries.sort { $0.score > $1.score }  // Sort descending
        entries = Array(entries.prefix(25))    // Keep top 25
        saveLeaderboard(entries)
    }

    // MARK: - Play Mode Leaderboard Persistence

    func savePlayLeaderboard(_ entries: [LeaderboardEntry]) {
        if let encoded = try? JSONEncoder().encode(entries) {
            defaults.set(encoded, forKey: Keys.playLeaderboard)
        }
    }

    func loadPlayLeaderboard() -> [LeaderboardEntry] {
        guard let data = defaults.data(forKey: Keys.playLeaderboard),
              let entries = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) else {
            return []
        }
        return entries
    }

    func addPlayLeaderboardEntry(_ entry: LeaderboardEntry) {
        var entries = loadPlayLeaderboard()
        entries.append(entry)
        entries.sort { $0.score > $1.score }  // Sort descending
        entries = Array(entries.prefix(25))    // Keep top 25
        savePlayLeaderboard(entries)
    }

    // MARK: - Graduated Mode Word Count Tracking

    func incrementWordCount(for level: Int) {
        let key = Keys.graduatedWordCount + "\(level)"
        let current = defaults.integer(forKey: key)
        defaults.set(current + 1, forKey: key)
    }

    func getWordCount(for level: Int) -> Int {
        let key = Keys.graduatedWordCount + "\(level)"
        return defaults.integer(forKey: key)
    }

    func isLevelUnlocked(_ level: Int) -> Bool {
        // Level 5 (first level) is always unlocked
        if level == 5 {
            return true
        }
        // Check if previous level has 20+ completions
        let previousLevel = level - 1
        return getWordCount(for: previousLevel) >= 20
    }

    func resetGraduatedProgress() {
        for level in 5...9 {
            let key = Keys.graduatedWordCount + "\(level)"
            defaults.removeObject(forKey: key)

            let historyKey = Keys.graduatedLevelHistory + "\(level)"
            defaults.removeObject(forKey: historyKey)
        }
    }

    // MARK: - Graduated Level Word History

    func saveLevelHistory(_ history: [WordAttempt], for level: Int) {
        let key = Keys.graduatedLevelHistory + "\(level)"
        if let encoded = try? JSONEncoder().encode(history) {
            defaults.set(encoded, forKey: key)
        }
    }

    func loadLevelHistory(for level: Int) -> [WordAttempt] {
        let key = Keys.graduatedLevelHistory + "\(level)"
        guard let data = defaults.data(forKey: key),
              let history = try? JSONDecoder().decode([WordAttempt].self, from: data) else {
            return []
        }
        return history
    }

    func addWordToLevelHistory(_ attempt: WordAttempt, for level: Int) {
        var history = loadLevelHistory(for: level)
        history.append(attempt)
        saveLevelHistory(history, for: level)
    }

    // MARK: - First Word Length Tracking

    func hasCompletedWordLength(_ length: Int) -> Bool {
        let key = Keys.firstWordLength + "\(length)"
        return defaults.bool(forKey: key)
    }

    func markWordLengthCompleted(_ length: Int) {
        let key = Keys.firstWordLength + "\(length)"
        defaults.set(true, forKey: key)
    }

    // MARK: - Debug Reset

    #if DEBUG
    /// Reset all app progress (DEBUG only)
    func resetAllProgress() {
        // Clear campaign progress
        clearCampaignProgress()

        // Clear graduated progress
        resetGraduatedProgress()

        // Clear leaderboards
        saveLeaderboard([])
        savePlayLeaderboard([])

        // Clear first word length tracking
        for length in 3...9 {
            let key = Keys.firstWordLength + "\(length)"
            defaults.removeObject(forKey: key)
        }

        // Reset current level to default
        defaults.removeObject(forKey: Keys.currentLevel)

        print("✅ All progress reset")
    }
    #endif
}
