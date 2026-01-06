import SwiftUI

struct HoldToConfirmButton: View {
    let title: String
    var icon: String? = nil
    let color: Color
    var isCompact: Bool = false
    let action: () -> Void

    @State private var progress: Double = 0
    @State private var isPressing = false
    @State private var timer: Timer?
    @State private var hasTriggered = false
    @Environment(\.scenePhase) private var scenePhase

    private let holdDuration: Double = 1.0
    private let updateInterval: Double = 0.05

    var body: some View {
        ZStack(alignment: .leading) {
            // Base background
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
            
            // Progress fill
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 15)
                    .fill(color.opacity(0.4))
                    .frame(width: geo.size.width * CGFloat(progress))
            }
            
            // Content (Manual replication of MenuButton style for deep integration)
            HStack(spacing: isCompact ? 8 : 12) {
                if let iconName = icon {
                    Image(systemName: iconName)
                        .font(.system(size: isCompact ? 18 : 22, weight: .bold))
                }
                
                Text(title)
                    .font(.system(size: isCompact ? 18 : 22, weight: .bold, design: .rounded))
                    .lineLimit(1)
                
                if !isCompact && icon == nil {
                    Spacer()
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, isCompact ? 12 : 25)
            .padding(.vertical, isCompact ? 10 : 18)
            .frame(maxWidth: .infinity)
        }
        .frame(height: isCompact ? 44 : 64)
        .contentShape(RoundedRectangle(cornerRadius: 15))
        .scaleEffect(isPressing ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressing)
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
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                stopPressing()
            }
        }
    }
    
    private func startPressing() {
        isPressing = true
        hasTriggered = false
        progress = 0
        
        // Initial tick
        UISelectionFeedbackGenerator().selectionChanged()
        
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            withAnimation(.linear(duration: updateInterval)) {
                progress += updateInterval / holdDuration
            }
            
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
            withAnimation(.easeOut(duration: 0.2)) {
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
        
        // Brief delay to show full progress before triggering and resetting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            action()
            reset()
        }
    }
    
    private func reset() {
        isPressing = false
        hasTriggered = false
        withAnimation {
            progress = 0
        }
    }
}
