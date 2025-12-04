import Foundation

/// Helper for hint system - rearranges scrambled letters to group pattern together
struct HintHelper {
    ///Rearrange scrambled word to place pattern letters adjacent in correct order
    /// Returns: (rearranged word, indices of pattern letters in rearranged word)
    static func rearrangeForHint(
        scrambled: String,
        targetWord: String,
        patternIndices: [Int]
    ) -> (rearranged: String, hintIndices: [Int], originalIndices: [Int]) {
        let scrambledArray = Array(scrambled)
        let targetArray = Array(targetWord.lowercased())
        
        // Get the pattern letters from target in correct order
        let patternLetters = patternIndices.map { targetArray[$0] }
        
        // Find these letters in scrambled word
        var scrambledIndices: [Int] = []
        var usedIndices = Set<Int>()
        
        for patternLetter in patternLetters {
            for (idx, letter) in scrambledArray.enumerated() {
                if letter.lowercased() == String(patternLetter) && !usedIndices.contains(idx) {
                    scrambledIndices.append(idx)
                    usedIndices.insert(idx)
                    break
                }
            }
        }
        
        // If we couldn't find all pattern letters, return original
        guard scrambledIndices.count == patternLetters.count else {
            return (scrambled, [], Array(0..<scrambled.count))
        }
        
        // Create rearranged word: pattern letters first, then rest
        var rearrangedArray: [Character] = []
        var newPatternIndices: [Int] = []
        var originalIndices: [Int] = []
        
        // Add pattern letters in correct order at the start
        for (i, letter) in patternLetters.enumerated() {
            newPatternIndices.append(rearrangedArray.count)
            rearrangedArray.append(letter)
            originalIndices.append(scrambledIndices[i])
        }
        
        // Add remaining letters
        for (idx, letter) in scrambledArray.enumerated() {
            if !usedIndices.contains(idx) {
                rearrangedArray.append(letter)
                originalIndices.append(idx)
            }
        }
        
        return (String(rearrangedArray), newPatternIndices, originalIndices)
    }
}
