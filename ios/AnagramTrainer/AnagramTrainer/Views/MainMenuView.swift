import SwiftUI

struct MainMenuView: View {
    @StateObject private var gameVM = GameViewModel()
    @StateObject private var campaignVM = CampaignViewModel()
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scalingFactor) var scalingFactor
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showingThemeDev = false
    
    // Local animation state to prevent global flicker during navigation
    @State private var overlayColor: Color = .clear
    @State private var showOverlay: Bool = false
    
    private let standardLight = Color(red: 0.95, green: 0.4, blue: 0.6)
    private let standardDark = Color(red: 0.25, green: 0.12, blue: 0.18)
    
    private var currentLightBase: Color {
        showOverlay ? overlayColor : standardLight
    }
    
    private var currentDarkBase: Color {
        showOverlay ? overlayColor : standardDark
    }
    
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
        colorScheme == .dark ? currentDarkBase : currentLightBase
    }

    // Navigation Path State
    @State private var path = NavigationPath()
    
    // Route Definition
    enum AppRoute: Hashable {
        case game
        case play // Graduated mode
        case train
        case campaign
        case leaderboard
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                // Layer 1: Base Gradient (Always visible)
                ThemeManager.shared.backgroundGradient(for: colorScheme == .dark ? standardDark : standardLight, colorScheme: colorScheme)
                    .ignoresSafeArea()
                
                // Layer 2: Overlay Gradient (Fades in on press)
                ThemeManager.shared.backgroundGradient(for: overlayColor, colorScheme: colorScheme)
                    .ignoresSafeArea()
                    .opacity(showOverlay ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.8), value: showOverlay)

                SpriteMenuBackgroundView(
                   gridSize: 6,
                   fontSize: 120.0,
                   rotationDuration: 180.0
                )
                .environment(\.themeBaseColor, standardLight)
                .environment(\.themeDarkBaseColor, standardDark)
                .ignoresSafeArea()
                // MenuBackgroundView(
                //     gridSize: 10,
                //     gap: 10.0 * scalingFactor,
                //     scale: 1.0,
                //     fontSize: 8.0,
                //     rotationDuration: 30.0
                // )
                // .ignoresSafeArea()

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
                                        .padding(.top, 6)
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

                    NavigationLink("Export Icons") {
                        AchievementExportView()
                    }
                    
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
                .onAppear {
                    // Reset overlay state when returning to main menu
                    showOverlay = false
                }
            } // closes GeometryReader
        } // closes ZStack
        .navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .game:
                GamePlayView(viewModel: gameVM, mode: .random)
            case .play:
                GraduatedDifficultySelector(viewModel: gameVM)
            case .train:
                TrainingMenuView(viewModel: gameVM)
            case .campaign:
                CampaignView(viewModel: campaignVM, onNavigateToLeaderboard: {
                    // Pop CampaignView and return to main menu
                    path.removeLast()
                })
            case .leaderboard:
                LeaderboardView()
            }
        }
    } // closes NavigationStack
    .tint(.white)
} // closes body
    
    

    @ViewBuilder
    private func menuButtons(isCompact: Bool) -> some View {
//        themeAnimatedNavigationButton(
//            route: .game,
//            title: "Try",
//            icon: "shuffle",
//            color: .cyan,
//            accentOverride: Color.cyan,
//            isCompact: isCompact
//        )

        themeAnimatedNavigationButton(
            route: .play,
            title: "Play",
            icon: "play.fill",
            color: .green,
            accentOverride: Color.green,
            isCompact: isCompact
        )

        themeAnimatedNavigationButton(
            route: .train,
            title: "Train",
            icon: "graduationcap",
            color: .purple,
            accentOverride: Color.purple,
            isCompact: isCompact
        )

        themeAnimatedNavigationButton(
            route: .campaign,
            title: "Challenge",
            icon: "trophy",
            color: Color(red: 1.0, green: 0.6, blue: 0.4),
            accentOverride: Color(red: 1.0, green: 0.6, blue: 0.4),
            isCompact: isCompact
        )

        themeAnimatedNavigationButton(
            route: .leaderboard,
            title: "Leaderboards",
            icon: "list.number",
            color: .indigo,
            accentOverride: .indigo,
            isCompact: isCompact
        )
    }

    @ViewBuilder
    private func themeAnimatedNavigationButton(
        route: AppRoute,
        title: String,
        icon: String,
        color: Color,
        accentOverride: Color,
        isCompact: Bool
    ) -> some View {
        Button(action: {
            // Keep overlay visible during navigation transition
            path.append(route)
        }) {
            MenuButton(
                title: title,
                icon: icon,
                color: color,
                isCompact: isCompact,
                textColor: .white
            )
        }
        .buttonStyle(PressedButtonStyle(onPressing: { isPressed in
            if isPressed {
                overlayColor = accentOverride
                showOverlay = true
            }
            // Don't hide overlay on release - let onAppear handle reset
        }))
    }
}

#Preview {
    MainMenuView()
}
