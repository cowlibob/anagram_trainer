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
    @State private var animationStartTime: Date = Date()

    private let standardLight = TrainingMode.graduated.color
    private let standardDark = TrainingMode.graduated.darkColor
    private let frequencyScalar: CGFloat = 3.0
    private let animationSpeed: CGFloat = 1.0 // radians per second

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
                        TimelineView(.animation) { context in
                            let elapsedTime = context.date.timeIntervalSince(animationStartTime)
                            let rawPhase = -CGFloat(elapsedTime) * animationSpeed
                            // Keep phase bounded using proper modulo for seamless looping
                            let twoPi = 2 * CGFloat.pi
                            let currentPhase = ((rawPhase.truncatingRemainder(dividingBy: twoPi)) + twoPi).truncatingRemainder(dividingBy: twoPi)

                            VStack(spacing: 0) {
                                ForEach(Array(levels.enumerated()), id: \.element.level) { index, node in
                                    VStack(spacing: 0) {
                                        // Node with alternating left/right offset
                                        HStack {
                                            if index % 2 == 1 {
                                                if index < levels.count - 1 {
                                                    wavyPath(
                                                        isUnlocked: persistence.isLevelUnlocked(levels[index + 1].level),
                                                        height: 110,
                                                        startOffset: index % 2 == 0 ? 1 : -1,
                                                        endOffset: (index + 1) % 2 == 0 ? 1 : -1,
                                                        frequency: Double(levels[index + 1].level - 4) * frequencyScalar,
                                                        phase: currentPhase
                                                    )
                                                } else if index == levels.count - 1 {
                                                    Spacer()
                                                }
                                            }
                                            levelNodeButton(node: node, geometry: geometry, index: index)
                                            if index % 2 == 0 {
                                                if index < levels.count - 1 {
                                                    wavyPath(
                                                        isUnlocked: persistence.isLevelUnlocked(levels[index + 1].level),
                                                        height: 110,
                                                        startOffset: index % 2 == 0 ? 1 : -1,
                                                        endOffset: (index + 1) % 2 == 0 ? 1 : -1,
                                                        frequency: Double(levels[index + 1].level - 4) * frequencyScalar,
                                                        phase: currentPhase
                                                    )
                                                } else if index == levels.count - 1 {
                                                    Spacer()
                                                }
                                            }
                                        }

                                        // Connecting path (except after last node)
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
            // Reset animation start time
            animationStartTime = Date()

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
    private func wavyPath(isUnlocked: Bool, height: CGFloat, startOffset: CGFloat, endOffset: CGFloat, frequency: Double, phase: CGFloat) -> some View {
        GeometryReader { geometry in
            WavyPathShape(
                width: geometry.size.width,
                height: height,
                startOffset: startOffset,
                endOffset: endOffset,
                frequency: frequency,
                phase: phase
            )
            .stroke(
                isUnlocked ? Color.white.opacity(0.4) : Color.white.opacity(0.2),
                style: StrokeStyle(
                    lineWidth: 3,
                    lineCap: .round
                )
            )
        }
        .frame(height: height * 1.5)
        .drawingGroup()
    }
}

// Custom Shape for animated wavy paths
struct WavyPathShape: Shape {
    var width: CGFloat
    var height: CGFloat
    var startOffset: CGFloat
    var endOffset: CGFloat
    var frequency: Double
    var phase: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let centerX = width / 2
        let amplitude: CGFloat = 80
        let nodeRadius: CGFloat = 110
        let waveAmplitude: CGFloat = 8

        // Node center positions
        let startNodeCenterX = centerX + (startOffset * amplitude)
        let endNodeCenterX = centerX - (endOffset * amplitude * 0.125)

        // Start from the outer edge of the starting node
        let startX = startNodeCenterX - (startOffset * nodeRadius)
        let startY: CGFloat = 25

        // End at the top of the ending node
        let endX = endNodeCenterX
        let endY = height * 1.5

        // Control points for the base smooth curve
        let controlPoint1X = startX + (startOffset * amplitude * 1.2)
        let controlPoint1Y = startY + (height * 0.5)
        let controlPoint2X = endX
        let controlPoint2Y = endY - (height * 0.4)

        // Sample points along the curve with sine wave perturbation
        let steps = 150
        var basePoints: [(point: CGPoint, tangent: CGPoint)] = []

        // First pass: generate base curve points and calculate tangents
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let oneMinusT = 1 - t

            // Cubic Bezier curve formula - broken into parts
            let t2 = t * t
            let t3 = t2 * t
            let oneMinusT2 = oneMinusT * oneMinusT
            let oneMinusT3 = oneMinusT2 * oneMinusT

            let term1X = oneMinusT3 * startX
            let term2X = 3 * oneMinusT2 * t * controlPoint1X
            let term3X = 3 * oneMinusT * t2 * controlPoint2X
            let term4X = t3 * endX
            let baseX = term1X + term2X + term3X + term4X

            let term1Y = oneMinusT3 * startY
            let term2Y = 3 * oneMinusT2 * t * controlPoint1Y
            let term3Y = 3 * oneMinusT * t2 * controlPoint2Y
            let term4Y = t3 * endY
            let baseY = term1Y + term2Y + term3Y + term4Y

            // Calculate tangent vector for perpendicular direction
            let diffX1 = controlPoint1X - startX
            let diffX2 = controlPoint2X - controlPoint1X
            let diffX3 = endX - controlPoint2X

            let tangentTerm1X = 3 * oneMinusT2 * diffX1
            let tangentTerm2X = 6 * oneMinusT * t * diffX2
            let tangentTerm3X = 3 * t2 * diffX3
            let tangentX = tangentTerm1X + tangentTerm2X + tangentTerm3X

            let diffY1 = controlPoint1Y - startY
            let diffY2 = controlPoint2Y - controlPoint1Y
            let diffY3 = endY - controlPoint2Y

            let tangentTerm1Y = 3 * oneMinusT2 * diffY1
            let tangentTerm2Y = 6 * oneMinusT * t * diffY2
            let tangentTerm3Y = 3 * t2 * diffY3
            let tangentY = tangentTerm1Y + tangentTerm2Y + tangentTerm3Y

            basePoints.append((
                point: CGPoint(x: baseX, y: baseY),
                tangent: CGPoint(x: tangentX, y: tangentY)
            ))
        }

        // Second pass: calculate cumulative arc length
        var arcLengths: [CGFloat] = [0]
        var totalLength: CGFloat = 0

        for i in 1..<basePoints.count {
            let prev = basePoints[i-1].point
            let curr = basePoints[i].point
            let dx = curr.x - prev.x
            let dy = curr.y - prev.y
            let segmentLength = sqrt(dx * dx + dy * dy)
            totalLength += segmentLength
            arcLengths.append(totalLength)
        }

        // Third pass: apply sine wave using arc length
        var points: [CGPoint] = []

        for i in 0..<basePoints.count {
            let basePoint = basePoints[i].point
            let tangent = basePoints[i].tangent

            // Normalize tangent
            let tangentXSquared = tangent.x * tangent.x
            let tangentYSquared = tangent.y * tangent.y
            let tangentLength = sqrt(tangentXSquared + tangentYSquared)
            guard tangentLength > 0 else {
                points.append(basePoint)
                continue
            }

            let normalizedTangentX = tangent.x / tangentLength
            let normalizedTangentY = tangent.y / tangentLength

            // Perpendicular is (-tangentY, tangentX) rotated 90 degrees
            let perpX = -normalizedTangentY
            let perpY = normalizedTangentX

            // Use normalized arc length (0 to 1) for constant frequency
            let normalizedArcLength = totalLength > 0 ? arcLengths[i] / totalLength : 0

            // Apply amplitude envelope at start and end (10% each) using smoothstep
            // Like an audio envelope: the wave continues throughout, we just attenuate it
            var envelope: CGFloat = 1.0
            if normalizedArcLength < 0.1 {
                // Fade in from 0 to 1 over first 10% using cubic smoothstep
                let t = normalizedArcLength / 0.1
                envelope = t * t * (3.0 - 2.0 * t)
            } else if normalizedArcLength > 0.9 {
                // Fade out from 1 to 0 over last 10% using cubic smoothstep
                let t = (1.0 - normalizedArcLength) / 0.1
                envelope = t * t * (3.0 - 2.0 * t)
            }

            // Calculate wave with continuous phase throughout entire path
            let sineInput = 2 * CGFloat.pi * CGFloat(frequency) * normalizedArcLength + phase
            // Apply envelope to amplitude only
            let waveOffset = waveAmplitude * sin(sineInput) * envelope

            let finalX = basePoint.x + perpX * waveOffset
            let finalY = basePoint.y + perpY * waveOffset

            points.append(CGPoint(x: finalX, y: finalY))
        }

        // Draw the path through all points
        if let firstPoint = points.first {
            path.move(to: firstPoint)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
        }

        return path
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
