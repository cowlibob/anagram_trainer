import Foundation
import SwiftUI

/// Training mode categories with associated pattern lists
enum TrainingMode: String, CaseIterable, Identifiable {
    case random = "Quick Play"
    case graduated = "Graduated Difficulty"
    case suffix = "Word Endings"
    case prefix = "Word Beginnings"
    case digraph = "Digraphs"
    case trigraph = "Trigraphs"
    case vowelCluster = "Vowel Clusters"
    case consonantBlend = "Consonant Blends"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .random:
            return "Random words from the dictionary"
        case .graduated:
            return "Automatically increases difficulty as you improve"
        case .suffix:
            return "Words ending in common patterns"
        case .prefix:
            return "Words starting with common patterns"
        case .digraph:
           return "Words containing consonant pairs"
        case .trigraph:
            return "Words with consonant clusters"
        case .vowelCluster:
            return "Words with vowel combinations"
        case .consonantBlend:
            return "Words with consonant blends"
        }
    }
    
    var icon: String {
        switch self {
        case .random: return "shuffle"
        case .graduated: return "chart.bar"
        case .suffix: return "arrow.right.to.line"
        case .prefix: return "arrow.left.to.line"
        case .digraph: return "2.circle"
        case .vowelCluster: return "a.circle"
        case .consonantBlend: return "b.circle"
        case .trigraph: return "3.circle"
        }
    }

    var color: Color {
        switch self {
        case .random: return .cyan
        case .graduated: return .green
        case .suffix: return .red
        case .prefix: return .blue
        case .digraph: return .purple
        case .vowelCluster: return .pink
        case .consonantBlend: return .teal
        case .trigraph: return .indigo
        }
    }

    var patterns: [String] {
        switch self {
        case .suffix:
            return ["ing", "tion", "ness", "able", "ment", "ized"]
        case .prefix:
            return ["un", "re", "pre", "dis", "over", "out"]
        case .digraph:
            return ["th", "sh", "ch", "ph", "wh"]
        case .trigraph:
            return ["str", "thr", "shr", "tch", "dge"]
        case .vowelCluster:
            return ["ie", "ea", "ou", "ee", "oo"]
        case .consonantBlend:
            return ["st", "bl", "br", "cl", "fl"]
        default:
            return []
        }
    }
    
    var hints: String {
        patterns.isEmpty ? "" : patterns.map { $0.uppercased() }.joined(separator: ", ")
    }
    
    /// Find the pattern in a word and return the indices and pattern string
    func findPattern(in word: String) -> (indices: [Int], pattern: String)? {
        let lowercased = word.lowercased()
        
        for pattern in patterns {
            // For suffix modes, check end of word
            if self == .suffix {
                if lowercased.hasSuffix(pattern) {
                    let startIndex = lowercased.count - pattern.count
                    let indices = Array(startIndex..<lowercased.count)
                    return (indices, pattern)
                }
            }
            // For prefix modes, check start of word
            else if self == .prefix {
                if lowercased.hasPrefix(pattern) {
                    let indices = Array(0..<pattern.count)
                    return (indices, pattern)
                }
            }
            // For cluster modes (digraph, trigraph, vowel, consonant), find substring
            else {
                if let range = lowercased.range(of: pattern) {
                    let startIdx = lowercased.distance(from: lowercased.startIndex, to: range.lowerBound)
                    let indices = Array(startIdx..<(startIdx + pattern.count))
                    return (indices, pattern)
                }
            }
        }
        return nil
    }
}
