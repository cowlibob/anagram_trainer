import SwiftUI

struct GameResultView: View {
    let word: String
    let solved: Bool
    let time: TimeInterval
    let definition: String
    let points: Int
    let onNext: () -> Void

    @Environment(\.scalingFactor) var scalingFactor
    @State private var revealedLetterCount: Int = 0
    @State private var showBonus: Bool = false
    @State private var showFinalScore: Bool = false

    // Calculate score components
    private var letterCount: Int { word.count }
    private var basePoints: Int { letterCount }
    private var bonusPoints: Int { max(0, letterCount - 5) }
    private var currentDisplayPoints: Int {
        if showFinalScore {
            return points
        } else if showBonus {
            return basePoints
        } else {
            return revealedLetterCount
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let isShort = geometry.size.height < 600

            ZStack {
                // Confetti for successful solves
                if solved {
                    ConfettiView()
                        .allowsHitTesting(false)
                        .zIndex(100)
                }

            VStack {
                Spacer()
                
                VStack(spacing: isShort ? 12 : 24) {
                    if !isShort {
                        Image(systemName: solved ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                            .font(.system(size: 60 * scalingFactor))
                            .foregroundColor(solved ? .green : .orange)
                    }

                    VStack(spacing: 4) {
                        Text(solved ? "Correct!" : "The word was:")
                            .font(isShort ? .subheadline : .title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        // Animated word reveal
                        HStack(spacing: 2) {
                            ForEach(0..<word.count, id: \.self) { index in
                                if index < revealedLetterCount {
                                    Text(String(word[word.index(word.startIndex, offsetBy: index)]).uppercased())
                                        .font(isShort ? .title : .largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(solved ? .green : ThemeManager.shared.lightBaseColor)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: revealedLetterCount)

                        // Animated score display
                        if solved {
                            VStack(spacing: 4) {
                                HStack(spacing: 8) {
                                    Text("\(currentDisplayPoints)")
                                        .font(.system(size: isShort ? 28 : 36, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                        .contentTransition(.numericText())

                                    Text(currentDisplayPoints == 1 ? "point" : "points")
                                        .font(.headline)
                                        .foregroundColor(.secondary)

                                    if showBonus && !showFinalScore && bonusPoints > 0 {
                                        Text("+\(bonusPoints) bonus")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.orange)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentDisplayPoints)
                                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showBonus)
                            }
                            .padding(.top, 8)
                        }
                    }

                    VStack {
                        if definition.isEmpty {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .tint(.secondary)
                                Text("Fetching definition...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            ScrollView {
                                Text(definition)
                                    .font(isShort ? .subheadline : .body)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .padding(isShort ? 10 : 20)
                            }
                        }
                    }
                    .frame(height: isShort ? 80 : 150) // Reduced height for short windows
                    .background(Color.primary.opacity(0.03))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    Button(action: onNext) {
                        MenuButton(title: "Next Word", icon: isShort ? nil : "arrow.right.circle", color: .blue, isCompact: isShort)
                    }
                    .buttonStyle(.plain)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .padding(.bottom, isShort ? 10 : 0)
                }
                .padding(isShort ? 20 : 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, isShort ? 20 : 40)
                .onAppear {
                    if solved {
                        startScoreAnimation()
                    } else {
                        // If not solved, show full word immediately
                        revealedLetterCount = word.count
                    }
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func startScoreAnimation() {
        // Reveal letters one at a time
        for i in 0..<word.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                withAnimation {
                    revealedLetterCount = i + 1
                }
            }
        }

        // After all letters shown, show bonus
        let bonusDelay = Double(word.count) * 0.2 + 0.3
        if bonusPoints > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + bonusDelay) {
                withAnimation {
                    showBonus = true
                }
            }

            // After bonus shown, show final score
            DispatchQueue.main.asyncAfter(deadline: .now() + bonusDelay + 0.8) {
                withAnimation {
                    showBonus = false
                    showFinalScore = true
                }
            }
        } else {
            // No bonus, go straight to final score
            DispatchQueue.main.asyncAfter(deadline: .now() + bonusDelay) {
                withAnimation {
                    showFinalScore = true
                }
            }
        }
    }
}
