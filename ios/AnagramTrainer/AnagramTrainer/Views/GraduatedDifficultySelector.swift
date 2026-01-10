import SwiftUI

struct GraduatedDifficultySelector: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scalingFactor) var scalingFactor
    @Environment(\.colorScheme) var colorScheme

    private let persistence = PersistenceManager.shared

    @State private var animatedBase: Color? = nil
    @State private var showConfetti = false
    @State private var animatingUnlock: Int? = nil

    private let standardLight = TrainingMode.graduated.color
    private let standardDark = TrainingMode.graduated.darkColor

    private var currentBase: Color {
        animatedBase ?? (colorScheme == .dark ? standardDark : standardLight)
    }

    // Level definitions with icons
    struct LevelNode {
        let level: Int
        let icon: String
        let color: Color
        let title: String
    }

    private let levels: [LevelNode] = [
        LevelNode(level: 5, icon: "star.fill", color: .cyan, title: "Beginner"),
        LevelNode(level: 6, icon: "flame.fill", color: .green, title: "Warming Up"),
        LevelNode(level: 7, icon: "bolt.fill", color: .orange, title: "Getting Hot"),
        LevelNode(level: 8, icon: "sparkles", color: .blue, title: "Challenging"),
        LevelNode(level: 9, icon: "crown.fill", color: .purple, title: "Master")
    ]

    var body: some View {
        ZStack {
            SpriteMenuBackgroundView(
                gridSize: 6,
                fontSize: 120.0,
                rotationDuration: 180.0
            )
            .ignoresSafeArea()

            // Confetti overlay
            if showConfetti || viewModel.showConfettiForUnlock {
                ConfettiView()
                    .allowsHitTesting(false)
                    .zIndex(100)
            }

            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
//                        VStack(spacing: 10) {
//                            Image(systemName: "chart.line.uptrend.xyaxis")
//                                .font(.system(size: 50 * scalingFactor))
//                                .foregroundStyle(.white)
//                                .padding(.bottom, 5)
//
//                            Text("Graduated Difficulty")
//                                .font(.largeTitle)
//                                .fontWeight(.bold)
//                                .foregroundColor(.white)
//
//                            Text("Complete 20 words to unlock the next level")
//                                .font(.subheadline)
//                                .foregroundColor(.white.opacity(0.9))
//                                .multilineTextAlignment(.center)
//                                .padding(.horizontal)
//                        }
//                        .padding(.top, 40)
//                        .padding(.bottom, 30)

                        // Ascending path of nodes
                        VStack(spacing: 0) {
                            ForEach(Array(levels.enumerated()), id: \.element.level) { index, node in
                                VStack(spacing: 0) {
                                    // Node
                                    levelNodeButton(node: node, geometry: geometry)

                                    // Connecting path (except after last node)
                                    if index < levels.count - 1 {
                                        wavyPath(
                                            isUnlocked: persistence.isLevelUnlocked(levels[index + 1].level),
                                            height: 80
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 60)
                    }
                }
            }
        }
//        .navigationTitle("Select Difficulty")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
        .environment(\.themeBaseColor, colorScheme == .dark ? standardDark : standardLight)
        .environment(\.themeDarkBaseColor, standardDark)
        .onAppear {
            // Check if we just unlocked a level
            if let unlockedLevel = viewModel.justUnlockedLevel {
                showConfetti = true
                animatingUnlock = unlockedLevel
                // Clear the flag after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showConfetti = false
                    viewModel.showConfettiForUnlock = false
                    viewModel.justUnlockedLevel = nil
                }
            }
        }
    }

    @ViewBuilder
    private func levelNodeButton(node: LevelNode, geometry: GeometryProxy) -> some View {
        let isUnlocked = persistence.isLevelUnlocked(node.level)
        let wordCount = persistence.getWordCount(for: node.level)
        let isAnimating = animatingUnlock == node.level

        NavigationLink(destination: GamePlayView(viewModel: viewModel, mode: .graduated)) {
            VStack(spacing: 8) {
                // Circular node
                ZStack {
                    // White background circle
                    Circle()
                        .fill(.white)
                        .frame(width: 100, height: 100)
                        .shadow(color: isUnlocked ? node.color.opacity(0.5) : .black.opacity(0.2),
                                radius: isUnlocked ? 15 : 8)

                    // Icon overlay
                    Image(systemName: node.icon)
                        .font(.system(size: 45, weight: .bold))
                        .foregroundStyle(
                            isUnlocked ? node.color : .white.opacity(0.3)
                        )

                    // Lock overlay for locked nodes
                    if !isUnlocked {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.7))
                                .frame(width: 100, height: 100)

                            Image(systemName: "lock.fill")
                                .font(.system(size: 35, weight: .bold))
                                .foregroundStyle(.gray.opacity(0.5))
                        }
                    }

                    // Level number badge
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(node.level)")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(
                                    Circle()
                                        .fill(isUnlocked ? node.color : .gray)
                                )
                                .offset(x: 10, y: 10)
                        }
                    }
                    .frame(width: 100, height: 100)
                }
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)

                // Title and progress
                VStack(spacing: 4) {
                    Text(node.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(isUnlocked ? .white : .white.opacity(0.5))

                    Text("\(node.level) Letters")
                        .font(.subheadline)
                        .foregroundColor(isUnlocked ? .white.opacity(0.9) : .white.opacity(0.4))

                    if isUnlocked {
                        // Progress indicator
                        HStack(spacing: 4) {
                            ForEach(0..<20, id: \.self) { index in
                                Circle()
                                    .fill(index < wordCount ? .white.opacity(0.3) : node.color)
                                    .frame(width: 9, height: 9)
                            }
                        }
                        .padding(.top, 4)

                        Text("\(wordCount)/20 completed")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Text("Locked")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.top, 4)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isUnlocked)
        .opacity(isUnlocked ? 1.0 : 0.6)
        .simultaneousGesture(TapGesture().onEnded {
            if isUnlocked {
                viewModel.currentLevel = node.level
                viewModel.streak = 0
                withAnimation(.easeInOut(duration: 0.4)) {
                    animatedBase = node.color
                }
            }
        })
    }

    @ViewBuilder
    private func wavyPath(isUnlocked: Bool, height: CGFloat) -> some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let startX = width / 2
                let startY: CGFloat = 0
                let endY = height

                // Create a wavy S-curve
                path.move(to: CGPoint(x: startX, y: startY))

                // Control points for bezier curve to create wave
                let controlPoint1X = startX + 30
                let controlPoint1Y = height * 0.25
                let controlPoint2X = startX - 30
                let controlPoint2Y = height * 0.5
                let midX = startX
                let midY = height * 0.5

                path.addCurve(
                    to: CGPoint(x: midX, y: midY),
                    control1: CGPoint(x: controlPoint1X, y: controlPoint1Y),
                    control2: CGPoint(x: controlPoint2X, y: controlPoint2Y)
                )

                let controlPoint3X = startX + 30
                let controlPoint3Y = height * 0.75
                let controlPoint4X = startX - 30
                let controlPoint4Y = height * 0.9

                path.addCurve(
                    to: CGPoint(x: startX, y: endY),
                    control1: CGPoint(x: controlPoint3X, y: controlPoint3Y),
                    control2: CGPoint(x: controlPoint4X, y: controlPoint4Y)
                )
            }
            .stroke(
                isUnlocked ? Color.white.opacity(0.4) : Color.white.opacity(0.2),
                style: StrokeStyle(
                    lineWidth: 3,
                    lineCap: .round,
                    dash: [8, 8]
                )
            )
        }
        .frame(height: height)
    }
}

// Navigation link wrapper for when nodes are tapped
extension GraduatedDifficultySelector {
    struct LevelNavigationButton: View {
        let node: LevelNode
        @ObservedObject var viewModel: GameViewModel
        let isUnlocked: Bool

        var body: some View {
            NavigationLink(destination: GamePlayView(viewModel: viewModel, mode: .graduated)) {
                EmptyView()
            }
        }
    }
}

#Preview {
    NavigationStack {
        GraduatedDifficultySelector(viewModel: GameViewModel())
    }
}
