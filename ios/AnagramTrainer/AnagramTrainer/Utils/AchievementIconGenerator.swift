import SwiftUI
import UIKit

/// Helper to generate achievement icons as transparent PNGs
struct AchievementIconGenerator {

    // MARK: - Achievement Icon Definitions

    struct IconConfig {
        let id: String
        let icon: String
        let color: Color
        let title: String
    }

    static let graduatedLevels: [IconConfig] = [
        IconConfig(id: "level_5", icon: "star.fill", color: .cyan, title: "Level 5"),
        IconConfig(id: "level_6", icon: "flame.fill", color: .green, title: "Level 6"),
        IconConfig(id: "level_7", icon: "bolt.fill", color: .orange, title: "Level 7"),
        IconConfig(id: "level_8", icon: "sparkles", color: .blue, title: "Level 8"),
        IconConfig(id: "level_9", icon: "crown.fill", color: .purple, title: "Level 9")
    ]

    static let campaignStages: [IconConfig] = [
        IconConfig(id: "campaign_stage_1", icon: "flame", color: .orange, title: "Warm Up"),
        IconConfig(id: "campaign_stage_2", icon: "character.textbox", color: .green, title: "Endings"),
        IconConfig(id: "campaign_stage_3", icon: "character.textbox", color: .blue, title: "Beginnings"),
        IconConfig(id: "campaign_stage_4", icon: "character.duployan", color: .purple, title: "Digraphs"),
        IconConfig(id: "campaign_stage_5", icon: "a.circle.fill", color: .red, title: "Vowels"),
        IconConfig(id: "campaign_stage_6", icon: "textformat.abc", color: .teal, title: "Consonants"),
        IconConfig(id: "campaign_stage_7", icon: "character.textbox", color: .pink, title: "Trigraphs"),
        IconConfig(id: "campaign_stage_8", icon: "trophy.fill", color: .yellow, title: "Boss Level")
    ]

    static let campaignComplete = IconConfig(
        id: "campaign_complete",
        icon: "medal.fill",
        color: .yellow,
        title: "Campaign Complete"
    )

    static let wordLengths: [IconConfig] = [
        IconConfig(id: "first_word_3", icon: "3.circle.fill", color: .cyan, title: "First 3-Letter"),
        IconConfig(id: "first_word_4", icon: "4.circle.fill", color: .green, title: "First 4-Letter"),
        IconConfig(id: "first_word_5", icon: "5.circle.fill", color: .blue, title: "First 5-Letter"),
        IconConfig(id: "first_word_6", icon: "6.circle.fill", color: .purple, title: "First 6-Letter"),
        IconConfig(id: "first_word_7", icon: "7.circle.fill", color: .orange, title: "First 7-Letter"),
        IconConfig(id: "first_word_8", icon: "8.circle.fill", color: .pink, title: "First 8-Letter"),
        IconConfig(id: "first_word_9", icon: "9.circle.fill", color: .red, title: "First 9-Letter")
    ]

    // MARK: - Icon View

    struct AchievementIconView: View {
        let config: IconConfig
        let size: CGFloat

        var body: some View {
            ZStack {
                // Circular background with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [config.color.opacity(0.8), config.color],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Icon
                Image(systemName: config.icon)
                    .font(.system(size: size * 0.45, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .frame(width: size, height: size)
        }
    }

    // MARK: - Export Function

    /// Generates transparent PNG data for an achievement icon
    static func generatePNG(config: IconConfig, size: CGFloat = 1024) -> Data? {
        let view = AchievementIconView(config: config, size: size)
        let controller = UIHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: size, height: size)
        controller.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        let image = renderer.image { context in
            controller.view.layer.render(in: context.cgContext)
        }

        return image.pngData()
    }

    /// Export all achievement icons to a directory
    static func exportAllIcons(to directory: URL, size: CGFloat = 1024) throws {
        let fileManager = FileManager.default

        // Create directory if it doesn't exist
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)

        var allConfigs: [(String, IconConfig)] = []

        // Add all configs with prefixes
        allConfigs += graduatedLevels.map { ("graduated_\($0.id)", $0) }
        allConfigs += campaignStages.map { ("\($0.id)", $0) }
        allConfigs.append(("campaign_complete", campaignComplete))
        allConfigs += wordLengths.map { ("\($0.id)", $0) }

        for (filename, config) in allConfigs {
            guard let pngData = generatePNG(config: config, size: size) else {
                print("Failed to generate PNG for \(filename)")
                continue
            }

            let fileURL = directory.appendingPathComponent("\(filename)_\(Int(size))x\(Int(size)).png")
            try pngData.write(to: fileURL)
            print("Exported: \(fileURL.lastPathComponent)")
        }

        print("✅ Exported \(allConfigs.count) achievement icons to \(directory.path)")
    }
}

// MARK: - Preview View

struct AchievementIconPreview: View {
    let size: CGFloat = 200

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                sectionView(title: "Graduated Levels", configs: AchievementIconGenerator.graduatedLevels)
                sectionView(title: "Campaign Stages", configs: AchievementIconGenerator.campaignStages)
                sectionView(title: "Campaign Complete", configs: [AchievementIconGenerator.campaignComplete])
                sectionView(title: "Word Lengths", configs: AchievementIconGenerator.wordLengths)
            }
            .padding()
        }
        .background(Color(.systemBackground))
    }

    func sectionView(title: String, configs: [AchievementIconGenerator.IconConfig]) -> some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: size))], spacing: 20) {
                ForEach(configs, id: \.id) { config in
                    VStack {
                        AchievementIconGenerator.AchievementIconView(
                            config: config,
                            size: size
                        )

                        Text(config.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    AchievementIconPreview()
}
