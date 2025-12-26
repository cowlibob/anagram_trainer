import SwiftUI

struct LeaderboardView: View {
    @State private var entries: [LeaderboardEntry] = []
    
    var body: some View {
        ZStack {
            MenuBackgroundView(
                gridSize: 10,
                gap: 50.0,
                scale: 1.0,
                fontSize: 8.0,
                rotationDuration: 30.0
            )
            .ignoresSafeArea()

            List {
                if entries.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "list.number")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.7))

                    Text("No scores yet")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Complete a campaign to appear here!")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 100)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    LeaderboardRow(entry: entry, rank: index + 1)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .navigationTitle("Leaderboard")
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
        }
        .onAppear {
            loadLeaderboard()
        }
    }
    
    private func loadLeaderboard() {
        entries = PersistenceManager.shared.loadLeaderboard()
    }
}

#Preview {
    NavigationStack {
        LeaderboardView()
    }
}
