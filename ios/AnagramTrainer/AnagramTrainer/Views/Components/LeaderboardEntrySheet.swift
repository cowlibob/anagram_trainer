import SwiftUI

struct LeaderboardEntrySheet: View {
    let score: Int
    let isPartial: Bool
    let onSubmit: (String) -> Void
    @State private var playerName = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Image(systemName: isPartial ? "exclamationmark.triangle" : "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(isPartial ? Color.orange.gradient : Color.yellow.gradient)
                
                Text(isPartial ? "Campaign Ended Early" : "Campaign Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Score: \(score)")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(spacing: 15) {
                    Text("Enter your name for the leaderboard:")
                        .font(.headline)
                    
                    TextField("Player Name", text: $playerName)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    Button(action: {
                        if !playerName.isEmpty {
                            onSubmit(playerName)
                            dismiss()
                        }
                    }) {
                        Text("Submit Score")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.gradient)
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    .disabled(playerName.isEmpty)
                }
            }
            .padding()
            .navigationTitle("Submit Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
