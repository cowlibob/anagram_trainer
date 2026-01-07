import Foundation

/// Outcome of a single word attempt
enum WordOutcome: String, Codable {
    case correct   // Valid anagram, but not the seeded word
    case exact     // Matched the initial seeded word exactly
    case skipped   // User skipped the word
}

/// A single word attempt in a campaign session
struct WordAttempt: Codable, Identifiable {
    let id: UUID
    let word: String  // Target word (for leaderboard)
    let guessedWord: String?  // Actual guessed word (for pause menu)
    let duration: TimeInterval
    let outcome: WordOutcome

    init(word: String, guessedWord: String? = nil, duration: TimeInterval, outcome: WordOutcome) {
        self.id = UUID()
        self.word = word
        self.guessedWord = guessedWord
        self.duration = duration
        self.outcome = outcome
    }
}

/// Leaderboard entry with player info, score, and optional session history
struct LeaderboardEntry: Codable, Identifiable {
    let id: UUID
    let playerName: String
    let score: Int
    let date: Date
    let history: [WordAttempt]?
    
    init(playerName: String, score: Int, date: Date = Date(), history: [WordAttempt]? = nil) {
        self.id = UUID()
        self.playerName = playerName
        self.score = score
        self.date = date
        self.history = history
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
