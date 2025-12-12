import SwiftUI

struct MainMenuView: View {
    @StateObject private var gameVM = GameViewModel()
    @StateObject private var campaignVM = CampaignViewModel()

    private var isLargeDevice: Bool {
        UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                MenuBackgroundView(
                    gridSize: 10,
                    gap: isLargeDevice ? 50.0 : 10.0,
                    scale: 1.0,
                    fontSize: 8.0,
                    rotationDuration: 30.0
                )
                .ignoresSafeArea()

                VStack(spacing: 30) {
                    // Title
                    VStack(spacing: 16) {
                        Image("icon_logotype_only")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            .shadow(color: Color(red: 1.0, green: 0.3, blue: 0.5).opacity(0.3), radius: 12, x: 0, y: 4)

                        HStack {
                            Text("Letter")
                                .font(.custom("DIN Condensed", size: 64))
                                .kerning(2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.95),
                                            Color.white.opacity(0.85)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                .shadow(color: Color(red: 1.0, green: 0.3, blue: 0.5).opacity(0.3), radius: 12, x: 0, y: 4)
                                .padding(.trailing, -10)
                            Text("Shift")
                                .font(.custom("DIN Condensed", size: 64))
                                .kerning(2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.95),
                                            Color.white.opacity(0.85)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                .shadow(color: Color(red: 1.0, green: 0.3, blue: 0.5).opacity(0.3), radius: 12, x: 0, y: 4)
                                .padding(.top, 15)
                                .padding(.leading, 0)
                        }
                    }
                    .padding(.top, 50)

                    Spacer()

                    // Menu Options
                    VStack(spacing: 20) {
                        NavigationLink(destination: GamePlayView(viewModel: gameVM, mode: .random)) {
                            if #available(iOS 26.0, *) {
                                MenuButton(title: "Try", icon: "shuffle", color: .cyan)
                                    .buttonStyle(.glassProminent)
                            } else {
                                // Fallback on earlier versions
                                MenuButton(title: "Try", icon: "shuffle", color: .cyan)
                            }
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: TrainingMenuView(viewModel: gameVM)) {
                            MenuButton(title: "Train", icon: "graduationcap", color: .purple)
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: CampaignView(viewModel: campaignVM)) {
                            MenuButton(title: "Test", icon: "trophy", color: Color(red: 1.0, green: 0.6, blue: 0.4))
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: LeaderboardView()) {
                            MenuButton(title: "Leaderboard", icon: "list.number", color: .indigo)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 40)

                    Spacer()

                    Text("Master the art of anagrams")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 30)
                }
                .navigationBarHidden(true)

            }
            .environmentObject(gameVM)
            .environmentObject(campaignVM)
        }
        .tint(.white)
    }
}

#Preview {
    MainMenuView()
}
