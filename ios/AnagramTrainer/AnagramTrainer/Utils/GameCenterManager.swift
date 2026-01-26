import Foundation
import GameKit
import Combine

class GameCenterManager: NSObject, ObservableObject {
    static let shared = GameCenterManager()

    @Published var isAuthenticated = false
    @Published var lastError: Error?

    // Leaderboard IDs
    private let campaignLeaderboardID = "lettershift_campaign_scores"
    private let graduatedLeaderboardID = "lettershift_graduated_scores"

    // Achievement IDs
    private struct AchievementIDs {
        // Graduated mode level completions (5-9)
        static let graduatedLevel5 = "lettershift_level_5"
        static let graduatedLevel6 = "lettershift_level_6"
        static let graduatedLevel7 = "lettershift_level_7"
        static let graduatedLevel8 = "lettershift_level_8"
        static let graduatedLevel9 = "lettershift_level_9"

        // Campaign stage completions (1-8)
        static let campaignStage1 = "lettershift_campaign_stage_1"
        static let campaignStage2 = "lettershift_campaign_stage_2"
        static let campaignStage3 = "lettershift_campaign_stage_3"
        static let campaignStage4 = "lettershift_campaign_stage_4"
        static let campaignStage5 = "lettershift_campaign_stage_5"
        static let campaignStage6 = "lettershift_campaign_stage_6"
        static let campaignStage7 = "lettershift_campaign_stage_7"
        static let campaignStage8 = "lettershift_campaign_stage_8"

        // Campaign complete
        static let campaignComplete = "lettershift_campaign_complete"

        // First word length solves (3-9)
        static let firstWord3 = "lettershift_first_word_3"
        static let firstWord4 = "lettershift_first_word_4"
        static let firstWord5 = "lettershift_first_word_5"
        static let firstWord6 = "lettershift_first_word_6"
        static let firstWord7 = "lettershift_first_word_7"
        static let firstWord8 = "lettershift_first_word_8"
        static let firstWord9 = "lettershift_first_word_9"
    }

    override init() {
        super.init()
    }
    
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            if let error = error {
                self?.lastError = error
                return
            }
            
            if let vc = viewController {
                // In a SwiftUI app, you might need to present this via a RootViewController
                // For now, we'll assume authentication happens through the system banner if possible
                self?.present(viewController: vc)
            } else if localPlayer.isAuthenticated {
                self?.isAuthenticated = true
                print("Game Center Authenticated: \(localPlayer.alias)")
            } else {
                self?.isAuthenticated = false
                print("Game Center Authentication Disabled")
            }
        }
    }

    /// Get the current player's display name, or "Player" if not authenticated
    func getPlayerDisplayName() -> String {
        let localPlayer = GKLocalPlayer.local
        if localPlayer.isAuthenticated {
            return localPlayer.displayName.isEmpty ? localPlayer.alias : localPlayer.displayName
        } else {
            return "Player"
        }
    }

    enum LeaderboardType {
        case campaign
        case graduated
    }

    func submitScore(_ score: Int, to leaderboardType: LeaderboardType) {
        guard isAuthenticated else {
            print("Cannot submit score: Player not authenticated")
            return
        }

        let leaderboardID = switch leaderboardType {
        case .campaign: campaignLeaderboardID
        case .graduated: graduatedLeaderboardID
        }

        print("📊 Submitting score \(score) to \(leaderboardType) (ID: \(leaderboardID))")

        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID]) { error in
            if let error = error {
                print("❌ Error submitting score to \(leaderboardType) (ID: \(leaderboardID)): \(error.localizedDescription)")
            } else {
                print("✅ Successfully submitted score \(score) to \(leaderboardType) (ID: \(leaderboardID))")
            }
        }
    }

    // MARK: - Achievement Reporting

    func reportGraduatedLevelCompletion(level: Int) {
        guard isAuthenticated else { return }

        let achievementID: String
        switch level {
        case 5: achievementID = AchievementIDs.graduatedLevel5
        case 6: achievementID = AchievementIDs.graduatedLevel6
        case 7: achievementID = AchievementIDs.graduatedLevel7
        case 8: achievementID = AchievementIDs.graduatedLevel8
        case 9: achievementID = AchievementIDs.graduatedLevel9
        default: return
        }

        reportAchievement(achievementID)
    }

    func reportCampaignStageCompletion(stage: Int) {
        guard isAuthenticated else { return }

        let achievementID: String
        switch stage {
        case 0: achievementID = AchievementIDs.campaignStage1
        case 1: achievementID = AchievementIDs.campaignStage2
        case 2: achievementID = AchievementIDs.campaignStage3
        case 3: achievementID = AchievementIDs.campaignStage4
        case 4: achievementID = AchievementIDs.campaignStage5
        case 5: achievementID = AchievementIDs.campaignStage6
        case 6: achievementID = AchievementIDs.campaignStage7
        case 7: achievementID = AchievementIDs.campaignStage8
        default: return
        }

        reportAchievement(achievementID)
    }

    func reportCampaignComplete() {
        guard isAuthenticated else { return }
        reportAchievement(AchievementIDs.campaignComplete)
    }

    func reportFirstWordLength(_ length: Int) {
        guard isAuthenticated else { return }

        let achievementID: String
        switch length {
        case 3: achievementID = AchievementIDs.firstWord3
        case 4: achievementID = AchievementIDs.firstWord4
        case 5: achievementID = AchievementIDs.firstWord5
        case 6: achievementID = AchievementIDs.firstWord6
        case 7: achievementID = AchievementIDs.firstWord7
        case 8: achievementID = AchievementIDs.firstWord8
        case 9: achievementID = AchievementIDs.firstWord9
        default: return
        }

        reportAchievement(achievementID)
    }

    private func reportAchievement(_ identifier: String) {
        let achievement = GKAchievement(identifier: identifier)
        achievement.percentComplete = 100.0
        achievement.showsCompletionBanner = true

        GKAchievement.report([achievement]) { error in
            if let error = error {
                print("Error reporting achievement \(identifier): \(error.localizedDescription)")
            } else {
                print("Successfully reported achievement: \(identifier)")
            }
        }
    }
    
    func showLeaderboard(_ type: LeaderboardType = .campaign) {
        guard isAuthenticated else {
            authenticateLocalPlayer()
            return
        }

        let leaderboardID = switch type {
        case .campaign: campaignLeaderboardID
        case .graduated: graduatedLeaderboardID
        }

        let gcVC = GKGameCenterViewController(
            leaderboardID: leaderboardID,
            playerScope: .global,
            timeScope: .allTime
        )
        gcVC.gameCenterDelegate = self
        present(viewController: gcVC)
    }

    func fetchTopScores(for type: LeaderboardType = .campaign) async throws -> [LeaderboardEntry] {
        guard isAuthenticated else {
            throw NSError(domain: "GameCenterManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }

        let leaderboardID = switch type {
        case .campaign: campaignLeaderboardID
        case .graduated: graduatedLeaderboardID
        }

        let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardID])
        guard let leaderboard = leaderboards.first else {
            return []
        }

        let (_, entries, _) = try await leaderboard.loadEntries(
            for: .global,
            timeScope: .allTime,
            range: NSRange(location: 1, length: 50)
        )

        return entries.map { entry in
            LeaderboardEntry(
                playerName: entry.player.displayName,
                score: entry.score,
                date: entry.date
            )
        }
    }
    
    private func present(viewController: UIViewController) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else { return }
            
            var topVC = rootVC
            while let presentedVC = topVC.presentedViewController {
                topVC = presentedVC
            }
            
            topVC.present(viewController, animated: true)
        }
    }
}

extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        DispatchQueue.main.async {
            gameCenterViewController.dismiss(animated: true)
        }
    }
}
