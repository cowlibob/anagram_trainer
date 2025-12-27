import SwiftUI

struct MainMenuView: View {
    @StateObject private var gameVM = GameViewModel()
    @StateObject private var campaignVM = CampaignViewModel()
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scalingFactor) var scalingFactor
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showingThemeDev = false
    
    private var titleGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(0.95),
                Color.white.opacity(0.85)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var accentColor: Color {
        colorScheme == .dark ? theme.darkBaseColor : theme.lightBaseColor
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MenuBackgroundView(
                    gridSize: 10,
                    gap: 10.0 * scalingFactor,
                    scale: 1.0,
                    fontSize: 8.0,
                    rotationDuration: 30.0
                )
                .ignoresSafeArea()

            GeometryReader { geometry in
                let isShort = geometry.size.height < 600
                
                VStack(spacing: isShort ? 10 : 30) {
                    // Title
                    Group {
                        if isShort {
                            HStack(spacing: 15) {
                                Image(colorScheme == .dark ? "icon_logotype_only_dark" : "icon_logotype_only")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 50 * scalingFactor)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                
                                HStack(spacing: 0) {
                                    Text("Letter")
                                        .font(.custom("DIN Condensed", size: 44 * scalingFactor))
                                        .kerning(1)
                                        .foregroundStyle(titleGradient)
                                    
                                    Text("Shift")
                                        .font(.custom("DIN Condensed", size: 44 * scalingFactor))
                                        .kerning(1)
                                        .foregroundStyle(titleGradient)
                                        .padding(.top, 10)
                                }
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                            .padding(.top, 20)
                        } else {
                            VStack(spacing: 16) {
                                Image(colorScheme == .dark ? "icon_logotype_only_dark" : "icon_logotype_only")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100 * scalingFactor)
                                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    .shadow(color: accentColor.opacity(0.3), radius: 12, x: 0, y: 4)

                                HStack {
                                    Text("Letter")
                                        .font(.custom("DIN Condensed", size: 64 * scalingFactor))
                                        .kerning(2)
                                        .foregroundStyle(titleGradient)
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                        .shadow(color: accentColor.opacity(0.3), radius: 12, x: 0, y: 4)
                                        .padding(.trailing, -10)
                                    Text("Shift")
                                        .font(.custom("DIN Condensed", size: 64 * scalingFactor))
                                        .kerning(2)
                                        .foregroundStyle(titleGradient)
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                        .shadow(color: accentColor.opacity(0.3), radius: 12, x: 0, y: 4)
                                        .padding(.top, 15)
                                }
                            }
                            .padding(.top, 50 * scalingFactor)
                        }
                    }
                    .onLongPressGesture(minimumDuration: 1.0) {
                        showingThemeDev = true
                    }

                    if !isShort {
                        Spacer()
                    }

                    // Menu Options
                    Group {
                        if horizontalSizeClass == .regular {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: isShort ? 12 : 20) {
                                menuButtons(isCompact: isShort)
                            }
                        } else {
                            VStack(spacing: isShort ? 12 : 20) {
                                menuButtons(isCompact: isShort)
                            }
                        }
                    }
                    .padding(.horizontal, isShort ? 20 : 40)

                    Spacer()

                    Text("Master the art of anagrams")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, isShort ? 10 : 30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .toolbar(.hidden, for: .navigationBar)
                .sheet(isPresented: $showingThemeDev) {
                    ThemeDevView()
                }
            }

            }
            .environmentObject(gameVM)
            .environmentObject(campaignVM)
        }
        .tint(.white)
    }

    @ViewBuilder
    private func menuButtons(isCompact: Bool) -> some View {
        NavigationLink(destination: GamePlayView(viewModel: gameVM, mode: .random)) {
            MenuButton(title: "Try", icon: "shuffle", color: .cyan, isCompact: isCompact)
        }.buttonStyle(.plain)

        NavigationLink(destination: TrainingMenuView(viewModel: gameVM)) {
            MenuButton(title: "Train", icon: "graduationcap", color: .purple, isCompact: isCompact)
        }
        .buttonStyle(.plain)

        NavigationLink(destination: CampaignView(viewModel: campaignVM)) {
            MenuButton(title: "Test", icon: "trophy", color: Color(red: 1.0, green: 0.6, blue: 0.4), isCompact: isCompact)
        }
        .buttonStyle(.plain)

        Button(action: {
            GameCenterManager.shared.showLeaderboard()
        }) {
            MenuButton(title: "Leaderboard", icon: "list.number", color: .indigo, isCompact: isCompact)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    MainMenuView()
}
