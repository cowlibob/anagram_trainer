import Foundation

/// Dictionary manager - loads and filters words from bundled text files
class Dictionary {
    static let shared = Dictionary()
    
    private var allWords: Set<String> = []
    private var suffixWords: [String] = []
    private var prefixWords: [String] = []
    private var digraphWords: [String] = []
    private var trigraphWords: [String] = []
    private var vowelClusterWords: [String] = []
    private var consonantBlendWords: [String] = []
    
    private var usedAnagramSignatures: Set<String> = []
    
    private init() {
        loadDictionaries()
    }
    
    private func loadDictionaries() {
        let words = loadWordList(filename: "dictionary")
        allWords = Set(words.map { $0.lowercased() })
        
        // Debug check for problematic words
        let checkWords = ["scrub", "broth"]
        for word in checkWords {
            if allWords.contains(word) {
            }
        }
        
        suffixWords = loadWordList(filename: "suffix_words")
        prefixWords = loadWordList(filename: "prefix_words")
        digraphWords = loadWordList(filename: "digraph_words")
        trigraphWords = loadWordList(filename: "trigraph_words")
        vowelClusterWords = loadWordList(filename: "vowel_cluster_words")
        consonantBlendWords = loadWordList(filename: "consonant_blend_words")
    }
    
    private func loadWordList(filename: String) -> [String] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("WARNING: Could not load \(filename).txt")
            return []
        }
        
        return content
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    /// Reset the anagram tracking (call when starting a new game session)
    func resetAnagramTracking() {
        usedAnagramSignatures.removeAll()
    }
    
    /// Get signature for anagram detection (sorted characters)
    private func anagramSignature(_ word: String) -> String {
        String(word.lowercased().sorted())
    }
    
    /// Select random word from appropriate list based on mode and length
    func randomWord(mode: TrainingMode, minLength: Int, maxLength: Int? = nil) -> String? {
        let candidates: [String]
        
        switch mode {
        case .random, .graduated:
            candidates = allWords.filter { word in
                let len = word.count
                if let max = maxLength {
                    return len >= minLength && len <= max
                } else {
                    return len >= minLength
                }
            }
        case .suffix:
            candidates = suffixWords.filter { $0.count >= minLength }
        case .prefix:
            candidates = prefixWords.filter { $0.count >= minLength }
        case .digraph:
            candidates = digraphWords.filter { $0.count >= minLength }
        case .trigraph:
            candidates = trigraphWords.filter { $0.count >= minLength }
        case .vowelCluster:
            candidates = vowelClusterWords.filter { $0.count >= minLength }
        case .consonantBlend:
            candidates = consonantBlendWords.filter { $0.count >= minLength }
        }
        
        guard !candidates.isEmpty else { return nil }
        
        // Filter out anagrams of words already used
        let filteredCandidates = candidates.filter { word in
            let signature = anagramSignature(word)
            return !usedAnagramSignatures.contains(signature)
        }
        
        // If all candidates have been used as anagrams, reset and use full list
        let finalCandidates = filteredCandidates.isEmpty ? candidates : filteredCandidates
        
        // Prefer shortest words at current level (Ruby behavior)
        let shortest = finalCandidates.min(by: { $0.count < $1.count })?.count ?? minLength
        let shortestWords = finalCandidates.filter { $0.count == shortest }
        
        guard let word = shortestWords.randomElement() else { return nil }
        
        // Track this anagram signature
        usedAnagramSignatures.insert(anagramSignature(word))
        
        return word
    }
    
    /// Scramble a word into an anagram
    func scramble(_ word: String) -> String {
        var letters = Array(word)
        
        // Keep shuffling until it's different from original
        var scrambled = letters
        repeat {
            scrambled.shuffle()
        } while String(scrambled) == word && word.count > 1
        
        return String(scrambled)
    }
    
    /// Check if a word exists in dictionary
    func wordExists(_ word: String) -> Bool {
        allWords.contains(word.lowercased())
    }
    
    /// Check if guess is a valid anagram of the target word
    /// Returns tuple: (isValid, validationTime in seconds)
    func isValidAnagram(guess: String, scrambledLetters: String) -> (Bool, TimeInterval) {
        let startTime = Date()
        
        // Check if guess uses exactly the same letters as scrambled
        let guessSignature = anagramSignature(guess)
        let scrambledSignature = anagramSignature(scrambledLetters)
        
        guard guessSignature == scrambledSignature else {
            let elapsed = Date().timeIntervalSince(startTime)
            return (false, elapsed)
        }
        
        // Check if it's a valid dictionary word
        let isValid = wordExists(guess)
        
        if !isValid {
        }
        
        let elapsed = Date().timeIntervalSince(startTime)
        
        return (isValid, elapsed)
    }
    /// Check if a guess can be formed from available letters (allows subset)
    /// Returns true if guess is a valid dictionary word and uses only available letters
    func canFormWord(guess: String, fromLetters letters: String) -> Bool {
        // Check if it's a valid dictionary word first
        guard wordExists(guess) else { return false }

        // Count available letters
        var availableLetters = letters.lowercased().reduce(into: [:]) { counts, char in
            counts[char, default: 0] += 1
        }

        // Check if each letter in guess is available
        for char in guess.lowercased() {
            guard let count = availableLetters[char], count > 0 else {
                return false
            }
            availableLetters[char] = count - 1
        }

        return true
    }

    /// Find all valid anagrams for a given set of letters
    func validAnagrams(for letters: String) -> [String] {
        let signature = anagramSignature(letters)
        return allWords.filter { anagramSignature($0) == signature }
    }
}
