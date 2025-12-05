import Foundation

/// Represents a single game state with word, guess, and timing information
struct GameState {
    let targetWord: String
    let scrambledWord: String
    var currentGuess: String = ""
    var positionOrder: [Int] = []  // Track order of positions for proper removal
    var cursorPosition: Int = 0  // Track cursor position for insertion (0 = start, length = end)
    var attempts: Int = 0
    let startTime: Date = Date()
    var endTime: Date?
    var pausedTime: Date?  // When timer was paused
    var totalPausedDuration: TimeInterval = 0  // Accumulated paused time
    var isComplete: Bool = false
    
    var usedPositions: Set<Int> {
        Set(positionOrder)
    }
    
    var elapsedTime: TimeInterval {
        let endPoint = endTime ?? (pausedTime ?? Date())
        return endPoint.timeIntervalSince(startTime) - totalPausedDuration
    }
    
    var isSolved: Bool {
        currentGuess.lowercased() == targetWord.lowercased()
    }
    
    mutating func addLetterAt(position: Int, letter: Character) {
        currentGuess.append(letter)
        positionOrder.append(position)
        cursorPosition = currentGuess.count // Move cursor to end
        attempts += 1
    }
    
    mutating func insertLetterAt(position: Int, letter: Character) {
        // Insert at cursor position
        let insertIndex = currentGuess.index(currentGuess.startIndex, offsetBy: cursorPosition)
        currentGuess.insert(letter, at: insertIndex)
        positionOrder.insert(position, at: cursorPosition)
        cursorPosition = min(cursorPosition + 1, currentGuess.count) // Advance cursor
        attempts += 1
    }
    
    mutating func removeLetter() {
        if !currentGuess.isEmpty {
            currentGuess.removeLast()
            positionOrder.removeLast()
            cursorPosition = currentGuess.count
        }
    }
    
    mutating func togglePosition(_ position: Int) {
        if let index = positionOrder.lastIndex(of: position) {
            // Remove the letter from guess at the same index
            let guessIndex = currentGuess.index(currentGuess.startIndex, offsetBy: index)
            currentGuess.remove(at: guessIndex)
            positionOrder.remove(at: index)
            // Adjust cursor if needed
            if cursorPosition > index {
                cursorPosition = max(0, cursorPosition - 1)
            }
        } else {
            // Position not used, insert at cursor
            let letter = Array(scrambledWord)[position]
            insertLetterAt(position: position, letter: letter)
        }
    }
    
    mutating func setCursorPosition(_ position: Int) {
        cursorPosition = max(0, min(position, currentGuess.count))
    }
    
    mutating func clearGuess() {
        currentGuess = ""
        positionOrder.removeAll()
        cursorPosition = 0
    }
    mutating func completeGame() {
        isComplete = true
        endTime = Date()
    }
    
    mutating func pauseTimer() {
        guard pausedTime == nil, !isComplete else { return }
        pausedTime = Date()
    }
    
    mutating func resumeTimer() {
        guard let paused = pausedTime, !isComplete else { return }
        totalPausedDuration += Date().timeIntervalSince(paused)
        pausedTime = nil
    }
}
