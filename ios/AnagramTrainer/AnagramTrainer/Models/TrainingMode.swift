import Foundation

/// Training mode categories with associated pattern lists
enum TrainingMode: String, CaseIterable, Identifiable {
    case random = "Random"
    case graduated = "Graduated Difficulty"
    case suffix = "Suffix Focus"
    case prefix = "Prefix Focus"
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
            return "Words ending in common suffixes"
        case .prefix:
            return "Words starting with common prefixes"
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
}
