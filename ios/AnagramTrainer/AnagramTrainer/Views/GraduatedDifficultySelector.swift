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
                                    // Node with alternating left/right offset
                                    HStack {
                                        if index % 2 == 1 {
                                            Spacer()
                                        }
                                        levelNodeButton(node: node, geometry: geometry, index: index)
                                        if index % 2 == 0 {
                                            Spacer()
                                        }
                                    }

                                    // Connecting path (except after last node)
                                    if index < levels.count - 1 {
                                        wavyPath(
                                            isUnlocked: persistence.isLevelUnlocked(levels[index + 1].level),
                                            height: 100,
                                            startOffset: index % 2 == 0 ? 1 : -1,
                                            endOffset: (index + 1) % 2 == 0 ? 1 : -1
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 80)
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
                // Delay the animation trigger slightly so the view can render first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animatingUnlock = unlockedLevel
                }
                // Pulse animation: scale up then back down
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    animatingUnlock = nil
                }
                // Clear the confetti and flags after the effect
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showConfetti = false
                    viewModel.showConfettiForUnlock = false
                    viewModel.justUnlockedLevel = nil
                }
            }
        }
    }

    @ViewBuilder
    private func levelNodeButton(node: LevelNode, geometry: GeometryProxy, index: Int) -> some View {
        let isUnlocked = persistence.isLevelUnlocked(node.level)
        let wordCount = persistence.getWordCount(for: node.level)
        let isAnimating = animatingUnlock == node.level

        NavigationLink(destination: GamePlayView(viewModel: viewModel, mode: .graduated)) {
            VStack(spacing: 8) {
                Spacer()
                // Circular node with progress dots around it
                ZStack {
                    // Progress dots in a circle around the button (only for unlocked levels)
                    if isUnlocked {
                        ForEach(0..<20, id: \.self) { dotIndex in
                            let angle = (2 * .pi / 20) * Double(dotIndex) - .pi / 2 // Start at top
                            let radius: CGFloat = 65 // Distance from center
                            let xOffset = radius * cos(angle)
                            let yOffset = radius * sin(angle)

                            Circle()
                                .fill(dotIndex < wordCount ? node.color : .white.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .offset(x: xOffset, y: yOffset)
                        }
                    }

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
                }
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)

                Spacer()
                // Title and progress text (centered)
                VStack(spacing: 4) {
                    Text(node.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(isUnlocked ? .white : .white.opacity(0.5))

                    Text("\(node.level) Letters")
                        .font(.subheadline)
                        .foregroundColor(isUnlocked ? .white.opacity(0.9) : .white.opacity(0.4))

                    if isUnlocked {
                        Text("\(wordCount)/20 completed")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 2)
                    } else {
                        Text("Locked")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.top, 2)
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
    private func wavyPath(isUnlocked: Bool, height: CGFloat, startOffset: CGFloat, endOffset: CGFloat) -> some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let centerX = width / 2
                let amplitude: CGFloat = 80 // Increased from 30 for wider meandering

                // Start and end positions based on node offsets
                // startOffset and endOffset are -1 (left) or 1 (right)
                let startX = centerX + (startOffset * amplitude)
                let endX = centerX + (endOffset * amplitude)

                let startY: CGFloat = 0
                let endY = height

                // Create a wider wavy S-curve connecting offset nodes
                path.move(to: CGPoint(x: startX, y: startY))

                // Control points for bezier curves with increased amplitude
                // First curve: from start to opposite side
                let controlPoint1X = startX + (startOffset * amplitude * 0.5)
                let controlPoint1Y = height * 0.2
                let controlPoint2X = centerX - (startOffset * amplitude * 1.2)
                let controlPoint2Y = height * 0.45
                let midX = centerX
                let midY = height * 0.5

                path.addCurve(
                    to: CGPoint(x: midX, y: midY),
                    control1: CGPoint(x: controlPoint1X, y: controlPoint1Y),
                    control2: CGPoint(x: controlPoint2X, y: controlPoint2Y)
                )

                // Second curve: from opposite side to end position
                let controlPoint3X = centerX + (endOffset * amplitude * 1.2)
                let controlPoint3Y = height * 0.55
                let controlPoint4X = endX - (endOffset * amplitude * 0.5)
                let controlPoint4Y = height * 0.8

                path.addCurve(
                    to: CGPoint(x: endX, y: endY),
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
