import SwiftUI

struct ModeInfoView: View {
    let mode: TrainingMode
    let onDismiss: () -> Void

    private var isLargeDevice: Bool {
        UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac
    }

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(mode.color.opacity(0.15))
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)

                Image(systemName: mode.icon)
                    .font(.system(size: 60))
                    .foregroundColor(mode.color)
                    .shadow(color: mode.color.opacity(0.5), radius: 10, x: 0, y: 5)
            }

            VStack(spacing: 8) {
                Text(mode.rawValue)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text(mode.description)
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            if !mode.patterns.isEmpty {
                VStack(spacing: 12) {
                    Text("Target Patterns")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary.opacity(0.8))
                        .textCase(.uppercase)

                    FlowLayout(spacing: 10) {
                        ForEach(mode.patterns, id: \.self) { pattern in
                            Text(pattern.uppercased())
                                .font(.system(.subheadline, design: .monospaced))
                                .fontWeight(.black)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(mode.color)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(color: mode.color.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .padding()
                .background(Color.primary.opacity(0.03))
                .cornerRadius(15)
            }

            Button(action: onDismiss) {
                MenuButton(title: "Start Training", icon: "play.fill", color: mode.color)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)
        }
        .padding(40)
        .background(
            Group {
                if #available(iOS 26.0, *) {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                } else {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                }
            }
        )
        .padding(isLargeDevice ? 100 : 20)
    }
}

// Simple FlowLayout for the patterns
struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > width {
                x = 0
                y += maxHeight + spacing
                maxHeight = 0
            }
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
        height = y + maxHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX {
                x = bounds.minX
                y += maxHeight + spacing
                maxHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        ModeInfoView(mode: .digraph, onDismiss: {})
    }
}
