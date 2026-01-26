import SwiftUI
import GameKit

struct LeaderboardView: View {
    enum LeaderboardScope: String, CaseIterable {
        case local = "Local"
        case global = "Global"
    }

    enum LeaderboardMode: String, CaseIterable {
        case play = "Play"
        case campaign = "Campaign"

        var title: String {
            switch self {
            case .play: return "Weekly Play Scores"
            case .campaign: return "Campaign High Scores"
            }
        }

        var icon: String {
            switch self {
            case .play: return "play.fill"
            case .campaign: return "trophy.fill"
            }
        }
    }

    @State private var campaignEntries: [LeaderboardEntry] = []
    @State private var playEntries: [LeaderboardEntry] = []
    @State private var selectedScope: LeaderboardScope = .local
    @State private var selectedMode: LeaderboardMode = .campaign
    @State private var isLoading = false
    @State private var errorMessage: String? = nil

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scalingFactor) var scalingFactor

    private let standardLight = Color.indigo
    private let standardDark = Color(red: 0.102, green: 0.102, blue: 0.251)

    private var currentEntries: [LeaderboardEntry] {
        selectedMode == .campaign ? campaignEntries : playEntries
    }

    var body: some View {
        ZStack {
            SpriteMenuBackgroundView(
               gridSize: 6,
               fontSize: 120.0,
               rotationDuration: 180.0
            )
            .environment(\.themeBaseColor, .indigo)
            .environment(\.themeDarkBaseColor, .indigo)
//            MenuBackgroundView(
//                gridSize: 10,
//                gap: 10.0 * scalingFactor,
//                scale: 1.0,
//                fontSize: 8.0,
//                rotationDuration: 30.0
//            )
//            .background(ThemeManager.shared.backgroundGradient(for: colorScheme == .dark ? standardDark : standardLight, colorScheme: colorScheme))
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Local/Global Segmented Control
                HStack(spacing: 0) {
                    ForEach(LeaderboardScope.allCases, id: \.self) { scope in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedScope = scope
                            }
                            loadLeaderboards()
                        }) {
                            Text(scope.rawValue)
                                .font(.custom("DIN Condensed", size: 20 * scalingFactor))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    selectedScope == scope ?
                                    Color.white.opacity(0.2) :
                                    Color.clear
                                )
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(4)
                .background(Color.black.opacity(0.2))
                .cornerRadius(12)
                .padding(.horizontal, 40)
                .padding(.top, 10)
                .padding(.bottom, 20)

                // Swipeable TabView for leaderboards
                TabView(selection: $selectedMode) {
                    ForEach(LeaderboardMode.allCases, id: \.self) { mode in
                        leaderboardContent(for: mode)
                            .tag(mode)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onChange(of: selectedMode) { _, _ in
                    loadLeaderboards()
                }

                // Page indicators at bottom
                HStack(spacing: 8) {
                    ForEach(LeaderboardMode.allCases, id: \.self) { mode in
                        Circle()
                            .fill(selectedMode == mode ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("LEADERBOARDS")
                    .font(.custom("DIN Condensed", size: 28 * scalingFactor))
                    .kerning(2)
                    .foregroundColor(.white)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAchievements()
                }) {
                    Image(systemName: "trophy.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
        .onAppear {
            loadLeaderboards()
        }
    }

    @ViewBuilder
    private func leaderboardContent(for mode: LeaderboardMode) -> some View {
        let entries = mode == .campaign ? campaignEntries : playEntries

        VStack(spacing: 0) {
            // Page title
            HStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.system(size: 18))
                Text(mode.title)
                    .font(.custom("DIN Condensed", size: 26 * scalingFactor))
                    .kerning(1)
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)

            if isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                    Text("Fetching Scores...")
                        .font(.custom("DIN Condensed", size: 24 * scalingFactor))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 20)
                    Spacer()
                }
            } else if let error = errorMessage {
                VStack {
                    Spacer()
                    VStack(spacing: 15) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.7))
                        Text(error)
                            .font(.headline)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        if error.contains("authenticated") {
                            Button("Sign in to Game Center") {
                                GameCenterManager.shared.authenticateLocalPlayer()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.white)
                            .foregroundColor(.indigo)
                        }
                    }
                    Spacer()
                }
            } else {
                List {
                    if entries.isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: mode == .campaign ? "trophy" : "play.circle")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.7))

                            Text("No scores yet")
                                .font(.headline)
                                .foregroundColor(.white)

                            Text(selectedScope == .global ?
                                 "Be the first to compete world-wide!" :
                                 mode == .campaign ? "Complete a campaign to appear here!" : "Play a session to appear here!")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 100)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    } else {
                        ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                            if selectedScope == .local && entry.history != nil && !entry.history!.isEmpty {
                                LeaderboardRow(entry: entry, rank: index + 1)
                                    .background(
                                        NavigationLink("", destination: mode == .campaign ?
                                            AnyView(CampaignHistoryView(entry: entry)) :
                                            AnyView(PlayHistoryView(entry: entry)))
                                            .opacity(0)
                                    )
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            } else {
                                LeaderboardRow(entry: entry, rank: index + 1)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }
    }

    private func loadLeaderboards() {
        errorMessage = nil

        if selectedScope == .local {
            // Load local leaderboards
            campaignEntries = PersistenceManager.shared.loadLeaderboard()
            playEntries = PersistenceManager.shared.loadPlayLeaderboard()
        } else {
            // Load global leaderboards from Game Center
            isLoading = true
            Task {
                do {
                    let gcType: GameCenterManager.LeaderboardType = selectedMode == .campaign ? .campaign : .graduated

                    let globalEntries = try await GameCenterManager.shared.fetchTopScores(for: gcType)
                    await MainActor.run {
                        if selectedMode == .campaign {
                            self.campaignEntries = globalEntries
                        } else {
                            self.playEntries = globalEntries
                        }
                        self.isLoading = false
                    }
                } catch {
                    await MainActor.run {
                        self.errorMessage = error.localizedDescription
                        self.isLoading = false
                        if selectedMode == .campaign {
                            self.campaignEntries = []
                        } else {
                            self.playEntries = []
                        }
                    }
                }
            }
        }
    }

    private func showAchievements() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let viewController = windowScene.windows.first?.rootViewController {
            let achievementVC = GKGameCenterViewController(state: .achievements)
            achievementVC.gameCenterDelegate = GameCenterCoordinator.shared
            viewController.present(achievementVC, animated: true)
        }
    }
}

// MARK: - Game Center Coordinator

class GameCenterCoordinator: NSObject, GKGameCenterControllerDelegate {
    static let shared = GameCenterCoordinator()

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}

#Preview {
    NavigationStack {
        LeaderboardView()
    }
}
