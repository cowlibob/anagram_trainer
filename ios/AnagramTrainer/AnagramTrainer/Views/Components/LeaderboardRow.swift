import SwiftUI

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let rank: Int

    var body: some View {
        HStack(spacing: 15) {
            // Rank with medal
            ZStack {
                Circle()
                    .fill(rankColor.gradient)
                    .frame(width: 40, height: 40)

                if rank <= 3 {
                    Image(systemName: medalIcon)
                        .foregroundColor(.white)
                        .font(.title3)
                } else {
                    Text("\(rank)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }

            // Player info - left aligned
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.playerName)
                    .font(.headline)
                    .foregroundColor(.white)

                Text(entry.formattedDate)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            // Score - right aligned
            Text("\(entry.score)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)  // Bronze
        default: return .blue
        }
    }
    
    private var medalIcon: String {
        switch rank {
        case 1: return "trophy.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return ""
        }
    }
}
