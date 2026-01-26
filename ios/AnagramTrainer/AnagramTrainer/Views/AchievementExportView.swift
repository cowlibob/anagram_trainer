import SwiftUI
import UIKit

/// Temporary view to export achievement icons
/// Add this to your app temporarily to generate the PNG files
struct AchievementExportView: View {
    @State private var exportStatus = "Ready to export"
    @State private var isExporting = false
    @State private var showShareSheet = false
    @State private var exportedURL: URL?

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

                    if let url = exportedURL {
                        Button("Share Folder") {
                            showShareSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
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
                    Text("2. Tap 'Share Folder' and save to Files/iCloud Drive")
                        .foregroundColor(.secondary)
                    Text("3. Save to a folder named 'LetterShift' for easy access")
                        .foregroundColor(.secondary)
                    Text("4. Also export 512x512 for the smaller size requirement")
                        .foregroundColor(.secondary)
                    Text("5. Upload both sizes to App Store Connect for each achievement")
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
        .sheet(isPresented: $showShareSheet) {
            if let url = exportedURL {
                ShareSheet(items: [url])
            }
        }
    }

    func exportIcons(size: CGFloat) {
        isExporting = true
        exportStatus = "Exporting \(Int(size))x\(Int(size)) icons..."

        // Must run on main thread for UIHostingController rendering
        DispatchQueue.main.async {
            do {
                // Create temporary directory for export
                let tempDir = FileManager.default.temporaryDirectory
                    .appendingPathComponent("LetterShift_\(Int(size))")

                // Remove if exists
                try? FileManager.default.removeItem(at: tempDir)

                // Export all icons to temp directory
                try AchievementIconGenerator.exportAllIcons(to: tempDir, size: size)

                exportedURL = tempDir
                exportStatus = "✅ Exported \(Int(size))x\(Int(size)) icons!\nTap 'Share Folder' to save to Files/iCloud."
                showShareSheet = true
                isExporting = false
            } catch {
                exportStatus = "❌ Error: \(error.localizedDescription)"
                isExporting = false
            }
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    AchievementExportView()
}
