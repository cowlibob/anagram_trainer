import Foundation

/// Leaderboard entry with player info and score
struct LeaderboardEntry: Codable, Identifiable {
    let id: UUID
    let playerName: String
    let score: Int
    let date: Date
    
    init(playerName: String, score: Int, date: Date = Date()) {
        self.id = UUID()
        self.playerName = playerName
        self.score = score
        self.date = date
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
