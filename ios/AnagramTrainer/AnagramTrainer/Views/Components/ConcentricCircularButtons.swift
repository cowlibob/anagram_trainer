import SwiftUI

struct ConcentricCircularButtons: View {
    let onSubmit: () -> Void
    let onClear: () -> Void
    let onSkip: () -> Void
    let isSubmitDisabled: Bool
    
    @ObservedObject var userSettings = UserSettings.shared
    @Environment(\.scalingFactor) var scalingFactor
    
    // Maximum radii (from center) - used on larger screens
    private let maxRSkip: CGFloat = 35    // Diameter 70
    private let maxRClearInner: CGFloat = 39
    private let maxRClearOuter: CGFloat = 139  // 100pt thickness
    private let maxRSubmitInner: CGFloat = 143
    private let maxRSubmitOuter: CGFloat = 283
    
    var body: some View {
        GeometryReader { geo in
            let isRight = userSettings.handedness == .right
            
            // Size the button cluster based on the smaller screen dimension
            let availableSize = min(geo.size.width, geo.size.height)
            // The cluster needs to fit within this, with the center at the corner
            // Only half the cluster (the NW/NE quadrant) is visible, so we can use full size if availableSize >= radius
            let clusterScale = min(1.0, availableSize / maxRSubmitOuter)
            
            // Scaled radii
            let rSkip = maxRSkip * clusterScale
            let rClearInner = maxRClearInner * clusterScale
            let rClearOuter = maxRClearOuter * clusterScale
            let rSubmitInner = maxRSubmitInner * clusterScale
            let rSubmitOuter = maxRSubmitOuter * clusterScale
            
            // NW bearing for right-handed, NE bearing for left-handed
            let textAngle: Angle = isRight ? .degrees(-135) : .degrees(-45)
            
            // The button cluster ZStack, centered at origin
            ZStack {
                // Submit Button (Outer Ring)
                Button(action: onSubmit) {
                    ZStack {
                        RingShape(innerRadius: rSubmitInner, outerRadius: rSubmitOuter)
                            .fill(Material.thickMaterial)
                        RingShape(innerRadius: rSubmitInner, outerRadius: rSubmitOuter)
                            .fill(isSubmitDisabled ? Color.gray.opacity(0.1) : Color.green.opacity(0.3))
                        RingShape(innerRadius: rSubmitInner, outerRadius: rSubmitOuter)
                            .stroke(isSubmitDisabled ? Color.white.opacity(0.1) : Color.green.opacity(0.5), lineWidth: 1)
                        
                        CurvedText(
                            text: "SUBMIT",
                            radius: (rSubmitInner + rSubmitOuter) / 2,
                            startAngle: textAngle,
                            fontSize: 20 * clusterScale,
                            color: isSubmitDisabled ? .white.opacity(0.3) : .white
                        )
                    }
                }
                .disabled(isSubmitDisabled)
                .buttonStyle(PlainButtonStyle())
                .frame(width: rSubmitOuter * 2, height: rSubmitOuter * 2)
                
                // Clear Button (Middle Ring)
                Button(action: onClear) {
                    ZStack {
                        RingShape(innerRadius: rClearInner, outerRadius: rClearOuter)
                            .fill(Material.thickMaterial)
                        RingShape(innerRadius: rClearInner, outerRadius: rClearOuter)
                            .fill(Color.yellow.opacity(0.3))
                        RingShape(innerRadius: rClearInner, outerRadius: rClearOuter)
                            .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                        
                        CurvedText(
                            text: "CLEAR",
                            radius: (rClearInner + rClearOuter) / 2,
                            startAngle: textAngle,
                            fontSize: 18 * clusterScale,
                            color: .white
                        )
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(width: rClearOuter * 2, height: rClearOuter * 2)
                
                // Skip Button (Center Circle with Hold-to-Confirm)
                CircularHoldButton(
                    baseRadius: rSkip,
                    maxRadius: rSubmitOuter,
                    action: onSkip
                )
            }
            // Position the ZStack so its center is at the corner
            .frame(width: rSubmitOuter * 2, height: rSubmitOuter * 2)
            .position(
                x: isRight ? geo.size.width : 0,
                y: geo.size.height
            )
        }
        .scaleEffect(scalingFactor)
        .ignoresSafeArea()
    }
}

// MARK: - Circular Hold-to-Confirm Button
struct CircularHoldButton: View {
    let baseRadius: CGFloat
    let maxRadius: CGFloat
    let action: () -> Void
    
    @State private var progress: Double = 0
    @State private var isPressing = false
    @State private var timer: Timer?
    @State private var hasTriggered = false
    
    private let holdDuration: Double = 1.0
    private let updateInterval: Double = 0.02
    
    // Scale factor interpolates from 1.0 to maxRadius/baseRadius based on progress
    private var scaleFactor: CGFloat {
        1.0 + CGFloat(progress) * (maxRadius / baseRadius - 1.0)
    }
    
    var body: some View {
        ZStack {
            // Base circle at fixed size, scaled up via transform
            Circle()
                .fill(Material.thickMaterial)
            
            Circle()
                .fill(Color.red.opacity(0.3))
            
            Circle()
                .stroke(Color.red.opacity(0.5), lineWidth: 1)
            
            // Icon stays at center
            Image(systemName: "forward.fill")
                .font(.system(size: 22))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                .scaleEffect(1.0 / scaleFactor) // Counter-scale to keep icon same size
        }
        .frame(width: baseRadius * 2, height: baseRadius * 2)
        .scaleEffect(scaleFactor)
        .animation(.easeOut(duration: 0.08), value: progress)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressing && !hasTriggered {
                        startPressing()
                    }
                }
                .onEnded { _ in
                    stopPressing()
                }
        )
    }
    
    private func startPressing() {
        isPressing = true
        hasTriggered = false
        progress = 0
        
        UISelectionFeedbackGenerator().selectionChanged()
        
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            progress += updateInterval / holdDuration
            
            if progress >= 1.0 {
                triggerAction()
            }
        }
    }
    
    private func stopPressing() {
        isPressing = false
        timer?.invalidate()
        timer = nil
        
        if !hasTriggered {
            withAnimation(.easeOut(duration: 0.3)) {
                progress = 0
            }
        }
    }
    
    private func triggerAction() {
        timer?.invalidate()
        timer = nil
        hasTriggered = true
        progress = 1.0
        
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            action()
            reset()
        }
    }
    
    private func reset() {
        isPressing = false
        hasTriggered = false
        withAnimation(.easeOut(duration: 0.3)) {
            progress = 0
        }
    }
}

// MARK: - Curved Text View
struct CurvedText: View {
    let text: String
    let radius: CGFloat
    let startAngle: Angle
    let fontSize: CGFloat
    let color: Color
    
    // Approximate angle per character based on font size and radius
    private var anglePerChar: Angle {
        .degrees(Double(fontSize) * 0.7 / radius * 180 / .pi)
    }
    
    var body: some View {
        ZStack {
            ForEach(Array(text.enumerated()), id: \.offset) { index, char in
                let charAngle = startAngle + anglePerChar * Double(index)
                
                Text(String(char))
                    .font(.system(size: fontSize, weight: .heavy, design: .rounded))
                    .foregroundColor(color)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                    .offset(y: -radius)
                    .rotationEffect(charAngle + .degrees(90)) // +90 to align tangent to arc
            }
        }
    }
}

// MARK: - Ring Shape
struct RingShape: Shape {
    let innerRadius: CGFloat
    let outerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        path.addArc(center: center, radius: outerRadius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
        path.addArc(center: center, radius: innerRadius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
        
        return path
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        ConcentricCircularButtons(
            onSubmit: {},
            onClear: {},
            onSkip: {},
            isSubmitDisabled: false
        )
    }
}
