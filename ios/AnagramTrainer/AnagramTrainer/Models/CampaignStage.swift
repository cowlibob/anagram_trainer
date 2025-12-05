import Foundation

/// Campaign stage definition matching Ruby CAMPAIGN_STAGES
struct CampaignStage {
    let name: String
    let mode: TrainingMode
    let length: Int?  // Specific word length for graduated modes
    let count: Int    // Number of words in this stage
    
    static let allStages: [CampaignStage] = [
        CampaignStage(name: "Warm Up", mode: .graduated, length: 5, count: 5),
        CampaignStage(name: "Word Endings", mode: .suffix, length: nil, count: 5),
        CampaignStage(name: "Word Beginnings", mode: .prefix, length: nil, count: 5),
        CampaignStage(name: "Digraphs", mode: .digraph, length: nil, count: 5),
        CampaignStage(name: "Vowel Clusters", mode: .vowelCluster, length: nil, count: 5),
        CampaignStage(name: "Consonant Blends", mode: .consonantBlend, length: nil, count: 5),
        CampaignStage(name: "Trigraphs", mode: .trigraph, length: nil, count: 5),
        CampaignStage(name: "Boss Level", mode: .graduated, length: 6, count: 10)
    ]
}
