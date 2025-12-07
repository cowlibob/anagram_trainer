import SwiftUI

struct MainMenuView: View {
    @StateObject private var gameVM = GameViewModel()
    @StateObject private var campaignVM = CampaignViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                MenuBackgroundView(
                    gridSize: 10,
                    gap: 50.0,
                    scale: 1.0,
                    fontSize: 8.0,
                    rotationDuration: 30.0
                )
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
                                MenuButton(title: "Quick Play", icon: "shuffle", color: .cyan)
                                    .buttonStyle(.glassProminent)
                            } else {
                                // Fallback on earlier versions
                                MenuButton(title: "Quick Play", icon: "shuffle", color: .cyan)
                            }
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: TrainingMenuView(viewModel: gameVM)) {
                            MenuButton(title: "Training Mode", icon: "graduationcap", color: .purple)
                        }
                        .buttonStyle(.plain)

                        NavigationLink(destination: CampaignView(viewModel: campaignVM)) {
                            MenuButton(title: "Train Me (Campaign)", icon: "trophy", color: Color(red: 1.0, green: 0.6, blue: 0.4))
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
                        .foregroundColor(.black.opacity(0.6))
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

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        if #available(iOS 26.0, *) {
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
                    .foregroundColor(.black.opacity(0.4))
            }
            .foregroundColor(.black)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(color.opacity(0.3))
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
            )
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        } else {
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
                    .foregroundColor(.black.opacity(0.4))
            }
            .foregroundColor(.black)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(color.opacity(0.3))
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                }
            )
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    MainMenuView()
}
