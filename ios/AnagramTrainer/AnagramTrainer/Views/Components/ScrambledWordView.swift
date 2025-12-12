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

    private var isLargeDevice: Bool {
        UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac
    }

    // Dynamic sizing based on word length and device
    private var letterSize: CGFloat {
        let length = scrambled.count
        if isLargeDevice {
            switch length {
            case ...6: return 70
            case 7: return 65
            case 8: return 58
            case 9: return 52
            default: return 48
            }
        } else {
            switch length {
            case ...6: return 70
            case 7: return 65
            case 8: return 58
            case 9: return 52
            default: return 48
//            case ...6: return 55
//            case 7: return 50
//            case 8: return 45
//            case 9: return 40
//            default: return 38
            }
        }
    }
    
    private var letterSpacing: CGFloat {
        scrambled.count > 7 ? 8 : 12
    }

    // Calculate letters per row ensuring at least 2 letters on each line
    private var lettersPerRow: Int {
        let count = displayWord.count
        if count <= 5 { return count }

        // Try splitting in half first
        let halfRounded = (count + 1) / 2
        if count % halfRounded >= 2 || count % halfRounded == 0 {
            return halfRounded
        }

        // Otherwise use 5 per row (works well for 6-10 letters)
        return min(5, count - 2)
    }

    var body: some View {
        Group {
            // Use wrapping layout for long words on small screens, or very long words on any screen
            if (!isLargeDevice && displayWord.count > 5) || displayWord.count > 8 {
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
