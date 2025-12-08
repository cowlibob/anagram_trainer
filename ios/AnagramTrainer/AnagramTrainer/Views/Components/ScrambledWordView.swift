import SwiftUI

struct ScrambledWordView: View {
    let scrambled: String
    let currentGuess: String
    let usedPositions: Set<Int>
    let mode: TrainingMode
    let targetWord: String
    let showHint: Bool
    let onLetterAction: (Int, Character) -> Void // Takes original index and character
    
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
    
    // Dynamic sizing based on word length
    private var letterSize: CGFloat {
        let length = scrambled.count
        switch length {
        case ...6: return 70
        case 7: return 65
        case 8: return 58
        case 9: return 52
        default: return 48
        }
    }
    
    private var letterSpacing: CGFloat {
        scrambled.count > 7 ? 8 : 12
    }
    
    var body: some View {
        Group {
            // Use wrapping layout for very long words
            if displayWord.count > 8 {
                VStack(spacing: 12) {
                    ForEach(Array(stride(from: 0, to: displayWord.count, by: 5)), id: \.self) { rowStart in
                        HStack(spacing: letterSpacing) {
                            ForEach(rowStart..<min(rowStart + 5, displayWord.count), id: \.self) { index in
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
