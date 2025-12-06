import SwiftUI

struct MainMenuView: View {
    @StateObject private var gameVM = GameViewModel()
    @StateObject private var campaignVM = CampaignViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                MenuBackgroundView(scale: 1.0)
                    .background(Color.pink)
                    .foregroundStyle(Color.white)
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    // Title
                    VStack(spacing: 10) {
                        Image(systemName: "textformat.abc")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue.gradient)

                        Text("Anagram Trainer")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    .padding(.top, 50)

                    Spacer()

                    // Menu Options
                    VStack(spacing: 20) {
                        NavigationLink(destination: GamePlayView(viewModel: gameVM, mode: .random)) {
                            MenuButton(title: "Play (Random)", icon: "shuffle", color: .blue)
                        }

                        NavigationLink(destination: TrainingMenuView(viewModel: gameVM)) {
                            MenuButton(title: "Training Mode", icon: "graduationcap", color: .green)
                        }

                        NavigationLink(destination: CampaignView(viewModel: campaignVM)) {
                            MenuButton(title: "Train Me (Campaign)", icon: "trophy", color: .orange)
                        }

                        NavigationLink(destination: LeaderboardView()) {
                            MenuButton(title: "Leaderboard", icon: "list.number", color: .purple)
                        }
                    }
                    .padding(.horizontal, 40)

                    Spacer()

                    Text("Improve your anagram solving skills")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 30)
                }
                .navigationBarHidden(true)

            }
            .environmentObject(gameVM)
            .environmentObject(campaignVM)
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 30)
            
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.gradient)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
}

#Preview {
    MainMenuView()
}
