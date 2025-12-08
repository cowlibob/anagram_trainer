import Foundation

struct KeyboardInputHelper {
    /// Builds a mapping from guess position to scrambled word position
    /// by matching each letter in the guess to available scrambled positions
    static func buildGuessToScrambledMapping(
        guess: String,
        scrambledWord: String,
        usedPositions: Set<Int>
    ) -> [Int] {
        var mapping: [Int] = []
        var availablePositions = usedPositions

        for char in guess {
            // Find the first available scrambled position with this character
            for (index, scrambledChar) in scrambledWord.enumerated() {
                if scrambledChar == char && availablePositions.contains(index) {
                    mapping.append(index)
                    availablePositions.remove(index)
                    break
                }
            }
        }

        return mapping
    }

    /// Returns the scrambled position that should be removed for a backspace at the given cursor position
    static func getPositionToRemove(
        cursorPosition: Int,
        guess: String,
        scrambledWord: String,
        usedPositions: Set<Int>
    ) -> Int? {
        guard cursorPosition > 0, !guess.isEmpty else { return nil }

        let mapping = buildGuessToScrambledMapping(
            guess: guess,
            scrambledWord: scrambledWord,
            usedPositions: usedPositions
        )

        guard mapping.count >= cursorPosition else { return nil }

        return mapping[cursorPosition - 1]
    }
}
