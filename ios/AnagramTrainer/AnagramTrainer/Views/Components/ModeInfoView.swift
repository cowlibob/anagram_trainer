import SwiftUI

struct ModeInfoView: View {
    let mode: TrainingMode
    let buttonTitle: String
    let onDismiss: () -> Void

    init(mode: TrainingMode, buttonTitle: String = "Start Training", onDismiss: @escaping () -> Void) {
        self.mode = mode
        self.buttonTitle = buttonTitle
        self.onDismiss = onDismiss
    }

    private var isLargeDevice: Bool {
        UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac
    }

    @Environment(\.scalingFactor) var scalingFactor
    
    var body: some View {
        GeometryReader { geometry in
            let isShort = geometry.size.height < 600
            
            VStack(spacing: isShort ? 12 : 24) {
                ZStack {
                    Circle()
                        .fill(mode.color.opacity(0.15))
                        .frame(width: isShort ? 60 : 100, height: isShort ? 60 : 100)
                        .blur(radius: isShort ? 10 : 20)

                    Image(systemName: mode.icon)
                        .font(.system(size: (isShort ? 30 : 60) * scalingFactor))
                        .foregroundColor(mode.color)
                        .shadow(color: mode.color.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .padding(.top, isShort ? 0 : 10)

                VStack(spacing: 4) {
                    Text(mode.rawValue)
                        .font(isShort ? .headline : .title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Text(mode.description)
                        .font(isShort ? .subheadline : .headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(isShort ? 2 : nil)
                }

                if !mode.patterns.isEmpty {
                    VStack(spacing: isShort ? 6 : 12) {
                        Text("Target Patterns")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary.opacity(0.8))
                            .textCase(.uppercase)

                        FlowLayout(spacing: isShort ? 6 : 10) {
                            ForEach(mode.patterns, id: \.self) { pattern in
                                Text(pattern.uppercased())
                                    .font(.system(isShort ? .caption : .subheadline, design: .monospaced))
                                    .fontWeight(.black)
                                    .padding(.horizontal, isShort ? 8 : 14)
                                    .padding(.vertical, isShort ? 4 : 8)
                                    .background(mode.color)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(isShort ? 10 : 16)
                    .background(Color.primary.opacity(0.03))
                    .cornerRadius(isShort ? 10 : 15)
                }

                Button(action: onDismiss) {
                    MenuButton(title: buttonTitle, icon: isShort ? nil : "play.fill", color: mode.color, isCompact: isShort)
                }
                .buttonStyle(.plain)
                .padding(.top, isShort ? 0 : 8)
            }
            .padding(isShort ? 20 : 40)
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
            .padding(.horizontal, isShort ? 20 : (isLargeDevice ? 100 : 20))
            .padding(.vertical, isShort ? 20 : (isLargeDevice ? 100 : 20))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
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
