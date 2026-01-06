import SwiftUI

struct ConcentricCircularButtons: View {
    let onSubmit: () -> Void
    let onClear: () -> Void
    let onSkip: () -> Void
    let isSubmitDisabled: Bool
    
    @ObservedObject var userSettings = UserSettings.shared
    @Environment(\.scalingFactor) var scalingFactor
    
    // Maximum radii (from center) - tuned for balanced layout
    private let maxRSkip: CGFloat = 40
    private let maxRClearInner: CGFloat = 45
    private let maxRClearOuter: CGFloat = 125 // Thickness 80
    private let maxRSubmitInner: CGFloat = 130
    private let maxRSubmitOuter: CGFloat = 210 // Thickness 80
    
    @State private var skipProgress: Double = 0
    @State private var clearProgress: Double = 0

    var body: some View {
        GeometryReader { geo in
            let isRight = userSettings.handedness == .right
            
            // Size the button cluster based on the smaller screen dimension
            let availableSize = min(geo.size.width, geo.size.height)
            // Ensure the radius fits within the screen with some margin
            let clusterScale = min(1.0, (availableSize * 0.8) / maxRSubmitOuter)
            
            // Scaled radii
            let rSubmitOuter = maxRSubmitOuter * clusterScale
            
            // NW bearing for right-handed, NE bearing for left-handed
            let textAngle: Angle = isRight ? .degrees(-135) : .degrees(-45)
            
            // Dynamic Layout Calculation
            let startThickness: CGFloat = 80.0
            let endThickness: CGFloat = 10.0
            let startGap: CGFloat = 5.0
            let endGap: CGFloat = 1.0

            // Base layout (when nothing is being held)
            let baseSubmitInner = rSubmitOuter - startThickness
            let baseClearOuter = baseSubmitInner - startGap
            let baseClearInner = baseClearOuter - startThickness
            let baseSkip = baseClearInner - startGap

            // Calculate radii based on which button is being held
            let (rSubmitInner, rClearOuter, rClearInner, rSkip, currentThickness): (CGFloat, CGFloat, CGFloat, CGFloat, CGFloat) = {
                if clearProgress > 0 {
                    // Clear button expansion mode
                    let clearInner = baseClearInner
                    let clearOuter = baseClearOuter + (rSubmitOuter - baseClearOuter - startGap) * clearProgress
                    let submitInner = clearOuter + startGap
                    let skip = baseSkip
                    return (submitInner, clearOuter, clearInner, skip, startThickness)
                } else {
                    // Skip button compression mode (original behavior)
                    let thickness = startThickness + (endThickness - startThickness) * skipProgress
                    let gap = startGap + (endGap - startGap) * skipProgress
                    let submitInner = rSubmitOuter - thickness
                    let clearOuter = submitInner - gap
                    let clearInner = clearOuter - thickness
                    let skip = clearInner - gap
                    return (submitInner, clearOuter, clearInner, skip, thickness)
                }
            }()

            // Submit button text scaling - scales down for both skip and clear
            let submitTextScale: CGFloat = {
                if clearProgress > 0 {
                    return 1.0 - (clearProgress * 0.875) // Scale down as clear grows
                } else {
                    return currentThickness / startThickness // Scale down as skip grows
                }
            }()
            
            // Corner offset based on fixed outer radius + margin
            let cornerOffset: CGFloat = (rSubmitOuter / 2) // Tuck it in nicely
            
            // The button cluster ZStack
            ZStack {
                // Skip Button (Center Circle) - Fills remaining space
                CircularHoldButton(
                    currentRadius: rSkip,
                    maxRadius: rSubmitOuter,
                    progress: $skipProgress,
                    otherProgress: $clearProgress,
                    action: onSkip
                )
                
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
                            fontSize: 20 * clusterScale * submitTextScale,
                            color: isSubmitDisabled ? .white.opacity(0.3) : .white
                        )
                        .opacity(submitTextScale > 0.25 ? 1.0 : 0.0)
                    }
                }
                .disabled(isSubmitDisabled)
                .buttonStyle(PlainButtonStyle())
                .frame(width: rSubmitOuter * 2, height: rSubmitOuter * 2)
                
                // Clear Button (Middle Ring)
                RingHoldButton(
                    innerRadius: rClearInner,
                    outerRadius: rClearOuter,
                    maxRadius: rSubmitOuter,
                    progress: $clearProgress,
                    otherProgress: $skipProgress,
                    textAngle: textAngle,
                    clusterScale: clusterScale,
                    currentThickness: currentThickness,
                    startThickness: startThickness,
                    action: onClear
                )
            }
            // Position the ZStack so its center is near the corner
            .frame(width: rSubmitOuter * 2, height: rSubmitOuter * 2)
            .position(
                x: isRight ? geo.size.width - cornerOffset : cornerOffset,
                y: geo.size.height - cornerOffset
            )
        }
        .scaleEffect(scalingFactor)
        .ignoresSafeArea()
    }
}

// MARK: - Circular Hold-to-Confirm Button
struct CircularHoldButton: View {
    let currentRadius: CGFloat
    let maxRadius: CGFloat
    @Binding var progress: Double
    @Binding var otherProgress: Double
    let action: () -> Void

    @State private var isPressing = false
    @State private var timer: Timer?
    @State private var hasTriggered = false
    @State private var isOutside = false
    @Environment(\.scenePhase) private var scenePhase

    private let holdDuration: Double = 1.0
    private let updateInterval: Double = 0.02
    
    var body: some View {
        ZStack {
            // Base circle at current dynamic size
            // Use RingShape for identical rendering characteristics to sibling buttons
            RingShape(innerRadius: 0, outerRadius: currentRadius)
                .fill(Material.thickMaterial)
            
            RingShape(innerRadius: 0, outerRadius: currentRadius)
                .fill(isOutside ? Color.gray.opacity(0.3) : Color.red.opacity(0.3))
            
            RingShape(innerRadius: 0, outerRadius: currentRadius)
                .stroke(isOutside ? Color.white.opacity(0.2) : Color.red.opacity(0.5), lineWidth: 1)
            
            // Text stays at center
            Text("SKIP")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(isOutside ? .white.opacity(0.5) : .white)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
        }
        .frame(width: maxRadius * 2, height: maxRadius * 2) // Stable frame for gesture
        .animation(.easeInOut(duration: 0.2), value: isOutside)
        .contentShape(Circle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if !isPressing && !hasTriggered {
                        startPressing()
                    }

                    // Fixed Interaction Logic:
                    // Calculate distance relative to the CENTER (maxRadius, maxRadius)
                    // instead of top-left (0,0).
                    let center = CGPoint(x: maxRadius, y: maxRadius)
                    let dx = value.location.x - center.x
                    let dy = value.location.y - center.y
                    let distance = sqrt(dx*dx + dy*dy)

                    let limit = maxRadius
                    isOutside = distance > limit
                }
                .onEnded { value in
                    let center = CGPoint(x: maxRadius, y: maxRadius)
                    let dx = value.location.x - center.x
                    let dy = value.location.y - center.y
                    let distance = sqrt(dx*dx + dy*dy)

                    let limit = maxRadius

                    if progress >= 1.0 && distance <= limit {
                        triggerAction()
                    } else {
                        cancelPressing()
                    }
                }
        )
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                cancelPressing()
            }
        }
    }
    
    private func startPressing() {
        isPressing = true
        hasTriggered = false
        isOutside = false
        progress = 0
        otherProgress = 0 // Cancel other button

        UISelectionFeedbackGenerator().selectionChanged()
        
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            if !isOutside {
                progress += updateInterval / holdDuration
                if progress > 1.0 { 
                    progress = 1.0
                    // Subtle haptic when "ready"
                    if !hasTriggered {
                        UISelectionFeedbackGenerator().selectionChanged()
                    }
                }
            } else {
                // Slowly decay progress if outside
                progress = max(0, progress - (updateInterval / holdDuration) * 2)
            }
        }
    }
    
    private func cancelPressing() {
        isPressing = false
        isOutside = false
        timer?.invalidate()
        timer = nil
        
        withAnimation(.easeOut(duration: 0.3)) {
            progress = 0
        }
    }
    
    private func triggerAction() {
        timer?.invalidate()
        timer = nil
        hasTriggered = true
        progress = 1.0
        
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            action()
            reset()
        }
    }
    
    private func reset() {
        isPressing = false
        hasTriggered = false
        isOutside = false
        withAnimation(.easeOut(duration: 0.3)) {
            progress = 0
        }
    }
}

// MARK: - Ring Hold-to-Confirm Button
struct RingHoldButton: View {
    let innerRadius: CGFloat
    let outerRadius: CGFloat
    let maxRadius: CGFloat
    @Binding var progress: Double
    @Binding var otherProgress: Double
    let textAngle: Angle
    let clusterScale: CGFloat
    let currentThickness: CGFloat
    let startThickness: CGFloat
    let action: () -> Void

    @State private var isPressing = false
    @State private var timer: Timer?
    @State private var hasTriggered = false
    @State private var isOutside = false
    @Environment(\.scenePhase) private var scenePhase

    private let holdDuration: Double = 1.0
    private let updateInterval: Double = 0.02

    var body: some View {
        ZStack {
            RingShape(innerRadius: innerRadius, outerRadius: outerRadius)
                .fill(Material.thickMaterial)
            RingShape(innerRadius: innerRadius, outerRadius: outerRadius)
                .fill(isOutside ? Color.gray.opacity(0.3) : Color.yellow.opacity(0.3))
            RingShape(innerRadius: innerRadius, outerRadius: outerRadius)
                .stroke(isOutside ? Color.white.opacity(0.2) : Color.yellow.opacity(0.5), lineWidth: 1)

            CurvedText(
                text: "CLEAR",
                radius: (innerRadius + outerRadius) / 2,
                startAngle: textAngle,
                fontSize: 18 * clusterScale * (currentThickness / startThickness),
                color: isOutside ? .white.opacity(0.5) : .white
            )
            .opacity(currentThickness > 20 ? 1.0 : 0.0)
        }
        .frame(width: maxRadius * 2, height: maxRadius * 2)
        .animation(.easeInOut(duration: 0.2), value: isOutside)
        .contentShape(RingShape(innerRadius: innerRadius, outerRadius: outerRadius))
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if !isPressing && !hasTriggered {
                        startPressing()
                    }

                    // Check if touch is within the ring
                    let center = CGPoint(x: maxRadius, y: maxRadius)
                    let dx = value.location.x - center.x
                    let dy = value.location.y - center.y
                    let distance = sqrt(dx*dx + dy*dy)

                    // Inside the ring if between inner and outer radius
                    isOutside = distance < innerRadius || distance > outerRadius
                }
                .onEnded { value in
                    let center = CGPoint(x: maxRadius, y: maxRadius)
                    let dx = value.location.x - center.x
                    let dy = value.location.y - center.y
                    let distance = sqrt(dx*dx + dy*dy)

                    let insideRing = distance >= innerRadius && distance <= outerRadius

                    if progress >= 1.0 && insideRing {
                        triggerAction()
                    } else {
                        cancelPressing()
                    }
                }
        )
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                cancelPressing()
            }
        }
    }

    private func startPressing() {
        isPressing = true
        hasTriggered = false
        isOutside = false
        progress = 0
        otherProgress = 0 // Cancel other button

        UISelectionFeedbackGenerator().selectionChanged()

        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            if !isOutside {
                progress += updateInterval / holdDuration
                if progress > 1.0 {
                    progress = 1.0
                    if !hasTriggered {
                        UISelectionFeedbackGenerator().selectionChanged()
                    }
                }
            } else {
                progress = max(0, progress - (updateInterval / holdDuration) * 2)
            }
        }
    }

    private func cancelPressing() {
        isPressing = false
        isOutside = false
        timer?.invalidate()
        timer = nil

        withAnimation(.easeOut(duration: 0.3)) {
            progress = 0
        }
    }

    private func triggerAction() {
        timer?.invalidate()
        timer = nil
        hasTriggered = true
        progress = 1.0

        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            action()
            reset()
        }
    }

    private func reset() {
        isPressing = false
        hasTriggered = false
        isOutside = false
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
    var innerRadius: CGFloat
    var outerRadius: CGFloat
    
    var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(innerRadius, outerRadius) }
        set {
            innerRadius = newValue.first
            outerRadius = newValue.second
        }
    }
    
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
