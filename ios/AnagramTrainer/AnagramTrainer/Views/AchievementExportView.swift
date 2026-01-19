import SwiftUI

/// Temporary view to export achievement icons
/// Add this to your app temporarily to generate the PNG files
struct AchievementExportView: View {
    @State private var exportStatus = "Ready to export"
    @State private var isExporting = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("Achievement Icon Export")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(exportStatus)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()

                VStack(spacing: 15) {
                    Button("Export 1024x1024 Icons") {
                        exportIcons(size: 1024)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isExporting)

                    Button("Export 512x512 Icons") {
                        exportIcons(size: 512)
                    }
                    .buttonStyle(.bordered)
                    .disabled(isExporting)
                }

                if isExporting {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding()
                }

                Divider()
                    .padding()

                VStack(alignment: .leading, spacing: 10) {
                    Text("Instructions:")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("1. Tap 'Export 1024x1024 Icons' to generate high-res files")
                        .foregroundColor(.secondary)
                    Text("2. Files will be saved to Documents/AchievementIcons/")
                        .foregroundColor(.secondary)
                    Text("3. Access via Files app or Finder (if Mac)")
                        .foregroundColor(.secondary)
                    Text("4. Upload to App Store Connect for each achievement")
                        .foregroundColor(.secondary)
                    Text("5. Also export 512x512 for the smaller size requirement")
                        .foregroundColor(.secondary)
                }
                .font(.caption)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                Spacer()
            }
            .padding()
        }
    }

    func exportIcons(size: CGFloat) {
        isExporting = true
        exportStatus = "Exporting \(Int(size))x\(Int(size)) icons..."

        // Must run on main thread for UIHostingController rendering
        DispatchQueue.main.async {
            do {
                // Get Documents directory
                let documentsPath = FileManager.default.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                )[0]
                let exportDirectory = documentsPath.appendingPathComponent("AchievementIcons")

                // Export all icons
                try AchievementIconGenerator.exportAllIcons(to: exportDirectory, size: size)

                exportStatus = "✅ Exported \(Int(size))x\(Int(size)) icons to:\n\(exportDirectory.path)"
                isExporting = false
            } catch {
                exportStatus = "❌ Error: \(error.localizedDescription)"
                isExporting = false
            }
        }
    }
}

#Preview {
    AchievementExportView()
}
