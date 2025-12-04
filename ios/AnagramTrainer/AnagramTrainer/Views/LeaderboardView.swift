import SwiftUI

struct LeaderboardView: View {
    @State private var entries: [LeaderboardEntry] = []
    
    var body: some View {
        List {
            if entries.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "list.number")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("No scores yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Complete a campaign to appear here!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 100)
                .listRowSeparator(.hidden)
            } else {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    LeaderboardRow(entry: entry, rank: index + 1)
                }
            }
        }
        .navigationTitle("Leaderboard")
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
