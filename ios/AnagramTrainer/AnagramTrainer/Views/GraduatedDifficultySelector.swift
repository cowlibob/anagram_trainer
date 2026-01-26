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
    @State private var expandedLevel: Int? = nil
    @State private var swipedLevel: Int? = nil
    @State private var hasShownHint = false
    @State private var isDragging: Bool = false
    @State private var hintOffsets: [Int: CGFloat] = [:]

    private let standardLight = TrainingMode.graduated.color
    private let standardDark = TrainingMode.graduated.darkColor
    private let frequencyScalar: CGFloat = 3.0
    private let animationSpeed: CGFloat = 1.0 // radians per second

    private var currentBase: Color {
        animatedBase ?? (colorScheme == .dark ? standardDark : standardLight)
    }

    @ViewBuilder
    private func animatedLevelNodes(geometry: GeometryProxy) -> some View {
        TimelineView(.animation) { context in
            let elapsedTime = context.date.timeIntervalSince(animationStartTime)
            let rawPhase = -CGFloat(elapsedTime) * animationSpeed
            let twoPi = CGFloat.pi * 2.0
            let remainder1 = rawPhase.truncatingRemainder(dividingBy: twoPi)
            let summed = remainder1 + twoPi
            let currentPhase = summed.truncatingRemainder(dividingBy: twoPi)

            VStack(spacing: 80) {
//                Spacer()
//                    .frame(height: 10)

                ForEach(Array(levels.enumerated()), id: \.element.level) { index, node in
                    VStack(spacing: 16) {
                        levelNodeButton(node: node, geometry: geometry, index: index)

                        // Expandable word history section (only show when both swiped and expanded)
                        if expandedLevel == node.level && swipedLevel == node.level {
                            wordHistorySection(for: node.level)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)
                                ))
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 60)
        .padding(.top, 30)
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
                        animatedLevelNodes(geometry: geometry)
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

            // Show swipe hint animation for completed levels with staggered delays
            if !hasShownHint {
                var delayIndex = 0
                for (index, level) in levels.enumerated() {
                    let wordCount = persistence.getWordCount(for: level.level)
                    if wordCount > 0 {
                        let baseDelay = 0.5 + (Double(delayIndex) * 0.15)
                        let levelId = level.level
                        let swipeLeft = index % 2 == 0

                        DispatchQueue.main.asyncAfter(deadline: .now() + baseDelay) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                hintOffsets[levelId] = swipeLeft ? -30 : 30
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    hintOffsets[levelId] = 0
                                }
                            }
                        }
                        delayIndex += 1
                    }
                }
                if delayIndex > 0 {
                    hasShownHint = true
                }
            }
        }
    }

    @ViewBuilder
    private func levelNodeButton(node: LevelNode, geometry: GeometryProxy, index: Int) -> some View {
        let isUnlocked = persistence.isLevelUnlocked(node.level)
        let wordCount = persistence.getWordCount(for: node.level)
        let isAnimating = animatingUnlock == node.level
        let hasHistory = wordCount > 0
        let isSwiped = swipedLevel == node.level
        let swipeLeft = index % 2 == 0  // Even rows slide left, odd rows slide right

        ZStack(alignment: swipeLeft ? .trailing : .leading) {
            // History button revealed by swipe (only for levels with history)
            if hasHistory {
                HStack {
                    if !swipeLeft {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                if expandedLevel == node.level {
                                    // Closing the list - hide button and slide back
                                    expandedLevel = nil
                                    swipedLevel = nil
                                } else {
                                    // Opening the list - keep button visible
                                    expandedLevel = node.level
                                }
                            }
                        }) {
                            Text("History")
                                .font(.custom("DIN Condensed", size: 18 * scalingFactor))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Spacer()
                    } else {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                if expandedLevel == node.level {
                                    // Closing the list - hide button and slide back
                                    expandedLevel = nil
                                    swipedLevel = nil
                                } else {
                                    // Opening the list - keep button visible
                                    expandedLevel = node.level
                                }
                            }
                        }) {
                            Text("History")
                                .font(.custom("DIN Condensed", size: 18 * scalingFactor))
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.white.opacity(0.3))
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .opacity(isSwiped ? 1.0 : 0.0)
            }

            // Main row content
            NavigationLink(destination: GamePlayView(viewModel: viewModel, mode: .graduated)) {
                HStack(spacing: 40) {
                    if index % 2 == 0 {
                        // Icon on left, text on right
                        circleIcon(node: node, isUnlocked: isUnlocked, wordCount: wordCount, isAnimating: isAnimating)
                        textContent(node: node, isUnlocked: isUnlocked, wordCount: wordCount, alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        // Text on left, icon on right
                        textContent(node: node, isUnlocked: isUnlocked, wordCount: wordCount, alignment: .trailing)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        circleIcon(node: node, isUnlocked: isUnlocked, wordCount: wordCount, isAnimating: isAnimating)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!isUnlocked || isSwiped)
            .opacity(isUnlocked ? 1.0 : 0.6)
            .offset(x: isSwiped ? (swipeLeft ? -120 : 120) : (hasHistory ? (hintOffsets[node.level] ?? 0) : 0))
            .simultaneousGesture(TapGesture().onEnded {
                if isUnlocked && !isSwiped {
                    viewModel.currentLevel = node.level
                    viewModel.streak = 0
                    withAnimation(.easeInOut(duration: 0.4)) {
                        animatedBase = node.color
                    }
                }
            })
            .highPriorityGesture(
                hasHistory ?
                DragGesture(minimumDistance: 10)
                    .onChanged { value in
                        isDragging = true

                        // Swipe direction depends on row layout
                        if swipeLeft {
                            // Even rows: swipe left to open, right to close
                            if value.translation.width < -20 {
                                withAnimation(.interactiveSpring()) {
                                    swipedLevel = node.level
                                }
                            } else if value.translation.width > 20 && isSwiped {
                                withAnimation(.interactiveSpring()) {
                                    swipedLevel = nil
                                    if expandedLevel == node.level {
                                        expandedLevel = nil
                                    }
                                }
                            }
                        } else {
                            // Odd rows: swipe right to open, left to close
                            if value.translation.width > 20 {
                                withAnimation(.interactiveSpring()) {
                                    swipedLevel = node.level
                                }
                            } else if value.translation.width < -20 && isSwiped {
                                withAnimation(.interactiveSpring()) {
                                    swipedLevel = nil
                                    if expandedLevel == node.level {
                                        expandedLevel = nil
                                    }
                                }
                            }
                        }
                    }
                    .onEnded { _ in
                        // Small delay before allowing taps again
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            isDragging = false
                        }
                    }
                : nil
            )
        }
        .contentShape(Rectangle())
        .onTapGesture {
            // Dismiss swipe on tap outside
            if isSwiped {
                withAnimation(.easeInOut(duration: 0.2)) {
                    swipedLevel = nil
                }
            }
        }
    }

    @ViewBuilder
    private func circleIcon(node: LevelNode, isUnlocked: Bool, wordCount: Int, isAnimating: Bool) -> some View {
        ZStack {
            // Progress dots in a circle around the button (always visible, white with varying opacity)
            ForEach(0..<20, id: \.self) { dotIndex in
                let angle = (2 * .pi / 20) * Double(dotIndex) - .pi / 2
                let radius: CGFloat = 65
                let xOffset = radius * cos(angle)
                let yOffset = radius * sin(angle)

                let dotOpacity: Double = if isUnlocked {
                    dotIndex < wordCount ? 1.0 : 0.3
                } else {
                    0.2
                }

                Circle()
                    .fill(Color.white.opacity(dotOpacity))
                    .frame(width: 8, height: 8)
                    .offset(x: xOffset, y: yOffset)
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
    }

    @ViewBuilder
    private func wordHistorySection(for level: Int) -> some View {
        let history = persistence.loadLevelHistory(for: level)

        VStack(spacing: 12) {
            if !history.isEmpty {
                ForEach(history) { attempt in
                    historyRow(attempt)
                }
            } else {
                Text("No words guessed yet")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.vertical, 20)
            }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private func historyRow(_ attempt: WordAttempt) -> some View {
        HStack(spacing: 15) {
            // Outcome Icon
            outcomeIcon(attempt.outcome)
                .font(.title2)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(attempt.word)
                        .font(.custom("DIN Condensed", size: 22 * scalingFactor))
                        .foregroundColor(.white)

                    if let guessed = attempt.guessedWord, guessed != attempt.word {
                        Text("(\(guessed))")
                            .font(.custom("DIN Condensed", size: 18 * scalingFactor))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Text(outcomeText(attempt.outcome))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                if attempt.outcome != .skipped {
                    Text("\(attempt.points) pts")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.green.opacity(0.9))

                    Text(String(format: "%.1fs", attempt.duration))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Text("0 pts")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    @ViewBuilder
    private func outcomeIcon(_ outcome: WordOutcome) -> some View {
        switch outcome {
        case .correct:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .exact:
            Image(systemName: "star.circle.fill")
                .foregroundColor(.yellow)
        case .skipped:
            Image(systemName: "arrow.right.circle.fill")
                .foregroundColor(.gray)
        }
    }

    private func outcomeText(_ outcome: WordOutcome) -> String {
        switch outcome {
        case .correct: return "Solved"
        case .exact: return "Exact Match"
        case .skipped: return "Skipped"
        }
    }

    @ViewBuilder
    private func textContent(node: LevelNode, isUnlocked: Bool, wordCount: Int, alignment: HorizontalAlignment) -> some View {
        VStack(alignment: alignment, spacing: 4) {
            Text(node.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isUnlocked ? .white : .white.opacity(0.5))

            Text("\(node.level) Letters")
                .font(.headline)
                .foregroundColor(isUnlocked ? .white.opacity(0.9) : .white.opacity(0.4))

            if isUnlocked {
                Text("\(wordCount)/20 completed")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 2)
            } else {
                Text("Locked")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.top, 2)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private func wavyPath(isUnlocked: Bool, height: CGFloat, startOffset: CGFloat, endOffset: CGFloat, frequency: Double, phase: CGFloat) -> some View {
        GeometryReader { geometry in
            ZStack {
                // Debug: Crossing guidelines at center
                Path { path in
                    let centerX = geometry.size.width / 2
                    let centerY = geometry.size.height / 2
                    // Horizontal line
                    path.move(to: CGPoint(x: 0, y: centerY))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: centerY))
                    // Vertical line
                    path.move(to: CGPoint(x: centerX, y: 0))
                    path.addLine(to: CGPoint(x: centerX, y: geometry.size.height))
                }
                .stroke(Color.white.opacity(0.5), lineWidth: 1)

                WavyPathShape(
                    width: geometry.size.width,
                    height: height * 0.8,
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
                .offset(x: 0.0, y: height * 0.4)
            }
        }
        .frame(height: height * 1.5)
        .border(Color.white, width: 2)
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
