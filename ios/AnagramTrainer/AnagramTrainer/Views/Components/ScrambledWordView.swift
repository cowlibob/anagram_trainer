import SwiftUI

struct ScrambledWordView: View {
    let scrambled: String
    let currentGuess: String
    let usedPositions: Set<Int>
    let mode: TrainingMode
    let targetWord: String
    let showHint: Bool
    let onLetterAction: (Int, Character) -> Void // Takes original index and character
    
    @Environment(\.scalingFactor) var scalingFactor
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var bounceAnimation = false
    
    // Compute hint arrangement if needed
    private var displayData: (word: String, hintIndices: Set<Int>, originalIndices: [Int]) {
        if showHint, let patternInfo = mode.findPattern(in: targetWord) {
            let result = HintHelper.rearrangeForHint(
                scrambled: scrambled,
                targetWord: targetWord,
                patternIndices: patternInfo.indices
            )
            return (result.rearranged, Set(result.hintIndices), result.originalIndices)
        }
        return (scrambled, [], Array(0..<scrambled.count))
    }
    
    private var displayWord: String { displayData.word }
    private var hintIndices: Set<Int> { displayData.hintIndices }
    private var originalIndices: [Int] { displayData.originalIndices }

    // Dynamic sizing based on word length and device
    private var letterSize: CGFloat {
        let length = scrambled.count
        let baseSize: CGFloat = horizontalSizeClass == .regular ? 70 : 65
        
        switch length {
        case ...6: return baseSize * min(1.2, scalingFactor)
        case 7: return baseSize * min(1.1, scalingFactor)
        case 8: return (baseSize - 7) * min(1.1, scalingFactor)
        case 9: return (baseSize - 13) * min(1.1, scalingFactor)
        default: return (baseSize - 17) * min(1.1, scalingFactor)
        }
    }
    
    private var letterSpacing: CGFloat {
        scrambled.count > 7 ? 8 : 12
    }

    // Calculate letters per row ensuring at least 2 letters on each line
    private var lettersPerRow: Int {
        switch displayWord.count {
        case 5, 6: return 3
        case 7, 8: return 4
        case 9, 10: return 5
        default: return 6
        }
    }

    var body: some View {
        Group {
            // Use wrapping layout for long words on compact screens or large/wide words
            if horizontalSizeClass == .compact || (displayWord.count > 7 && scalingFactor < 1.0) {
                VStack(spacing: 12) {
                    ForEach(Array(stride(from: 0, to: displayWord.count, by: lettersPerRow)), id: \.self) { rowStart in
                        HStack(spacing: letterSpacing) {
                            ForEach(rowStart..<min(rowStart + lettersPerRow, displayWord.count), id: \.self) { index in
                                let originalIndex = originalIndices[index]
                                LetterButtonView(
                                    letter: Array(displayWord)[index],
                                    isUsed: usedPositions.contains(originalIndex),
                                    isHint: hintIndices.contains(index),
                                    size: letterSize,
                                    onTap: {
                                        onLetterAction(originalIndex, Array(displayWord)[index])
                                    }
                                )
                            }
                        }
                    }
                }
            } else {
                HStack(spacing: letterSpacing) {
                    ForEach(Array(displayWord.enumerated()), id: \.offset) { index, letter in
                        let originalIndex = originalIndices[index]
                        LetterButtonView(
                            letter: letter,
                            isUsed: usedPositions.contains(originalIndex),
                            isHint: hintIndices.contains(index),
                            size: letterSize,
                            onTap: {
                                onLetterAction(originalIndex, letter)
                            }
                        )
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.5), value: displayWord)
        .onChange(of: showHint) {
            if showHint {
                bounceAnimation = true
            } else {
                bounceAnimation = false
            }
        }
    }
}
