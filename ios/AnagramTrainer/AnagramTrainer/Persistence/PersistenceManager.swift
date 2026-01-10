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
        static let graduatedWordCount = "anagram_trainer_graduated_word_count_"
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
        }
    }
}
