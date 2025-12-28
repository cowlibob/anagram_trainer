import Foundation
import GameKit
import Combine

class GameCenterManager: NSObject, ObservableObject {
    static let shared = GameCenterManager()
    
    @Published var isAuthenticated = false
    @Published var lastError: Error?
    
    private let leaderboardID = "lettershift_high_scores"
    
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
    
    func submitScore(_ score: Int) {
        guard isAuthenticated else {
            print("Cannot submit score: Player not authenticated")
            return
        }
        
        GKLeaderboard.submitScore(score, context: 0, player: GKLocalPlayer.local, leaderboardIDs: [leaderboardID]) { error in
            if let error = error {
                print("Error submitting score: \(error.localizedDescription)")
            } else {
            }
        }
    }
    
    func showLeaderboard() {
        guard isAuthenticated else {
            authenticateLocalPlayer()
            return
        }
        
        let gcVC = GKGameCenterViewController(
            leaderboardID: leaderboardID,
            playerScope: .global,
            timeScope: .allTime
        )
        gcVC.gameCenterDelegate = self
        present(viewController: gcVC)
    }

    func fetchTopScores() async throws -> [LeaderboardEntry] {
        guard isAuthenticated else {
            throw NSError(domain: "GameCenterManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
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
