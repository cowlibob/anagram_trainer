import SwiftUI

struct CampaignCompleteView: View {
    let score: Int
    let onSubmit: (String) -> Void
    @State private var playerName = ""

    var body: some View {
        ZStack {
            // Confetti overlay
            ConfettiView()
                .allowsHitTesting(false)
                .zIndex(100)

        VStack(spacing: 30) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundStyle(.yellow.gradient)
            
            Text("Campaign Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Final Score: \(score)")
                .font(.title)
                .foregroundColor(.blue)
            
            VStack(spacing: 15) {
                Text("Enter your name for the leaderboard:")
                    .font(.headline)
                
                TextField("Player Name", text: $playerName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 40)
                
                Button(action: {
                    if !playerName.isEmpty {
                        onSubmit(playerName)
                    }
                }) {
                    Text("Submit Score")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.gradient)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                .disabled(playerName.isEmpty)
            }
        }
        .padding()
        }
    }
}
