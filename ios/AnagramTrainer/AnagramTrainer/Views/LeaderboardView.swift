import SwiftUI

struct LeaderboardView: View {
    enum LeaderboardType: String, CaseIterable {
        case global = "Global"
        case local = "Local"
    }

    @State private var entries: [LeaderboardEntry] = []
    @State private var selectedType: LeaderboardType = .global
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scalingFactor) var scalingFactor
    
    var body: some View {
        ZStack {
            MenuBackgroundView(
                gridSize: 10,
                gap: 10.0 * scalingFactor,
                scale: 1.0,
                fontSize: 8.0,
                rotationDuration: 30.0
            )
            .background(ThemeManager.shared.backgroundGradient(for: .indigo, colorScheme: colorScheme))
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Picker
                HStack(spacing: 0) {
                    ForEach(LeaderboardType.allCases, id: \.self) { type in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedType = type
                            }
                            loadLeaderboard()
                        }) {
                            Text(type.rawValue)
                                .font(.custom("DIN Condensed", size: 20 * scalingFactor))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    selectedType == type ? 
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
                .padding(.bottom, 10)

                if isLoading {
                    Spacer()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                    Text("Fetching Scores...")
                        .font(.custom("DIN Condensed", size: 24 * scalingFactor))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 20)
                    Spacer()
                } else if let error = errorMessage {
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
                } else {
                    List {
                        if entries.isEmpty {
                            VStack(spacing: 15) {
                                Image(systemName: "list.number")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.7))

                                Text("No scores yet")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Text(selectedType == .global ? "Be the first to compete world-wide!" : "Complete a campaign to appear here!")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 100)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        } else {
                            ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                                if selectedType == .local && entry.history != nil && !entry.history!.isEmpty {
                                    NavigationLink(destination: CampaignHistoryView(entry: entry)) {
                                        LeaderboardRow(entry: entry, rank: index + 1)
                                    }
                                } else {
                                    LeaderboardRow(entry: entry, rank: index + 1)
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)
                }
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
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
        .onAppear {
            loadLeaderboard()
        }
    }

    private func loadLeaderboard() {
        errorMessage = nil
        
        if selectedType == .local {
            entries = PersistenceManager.shared.loadLeaderboard()
        } else {
            isLoading = true
            Task {
                do {
                    let globalEntries = try await GameCenterManager.shared.fetchTopScores()
                    await MainActor.run {
                        self.entries = globalEntries
                        self.isLoading = false
                    }
                } catch {
                    await MainActor.run {
                        self.errorMessage = error.localizedDescription
                        self.isLoading = false
                        self.entries = []
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        LeaderboardView()
    }
}
