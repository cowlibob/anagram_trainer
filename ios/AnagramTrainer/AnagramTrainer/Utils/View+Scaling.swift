import SwiftUI

struct ScalingFactorKey: EnvironmentKey {
    static let defaultValue: CGFloat = 1.0
}

extension EnvironmentValues {
    var scalingFactor: CGFloat {
        get { self[ScalingFactorKey.self] }
        set { self[ScalingFactorKey.self] = newValue }
    }
}

struct ScalingViewModifier: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            // Reference width is iPhone 15 Pro (approx 393 points)
            // We scale up or down based on this.
            // For iPad full screen, it will be much larger.
            // For Split View, it might be close to 320 or 400.
            // We clamp the lower bound to 0.8 to prevent UI from getting too small.
            let factor = max(0.8, width / 393.0)
            
            content
                .environment(\.scalingFactor, factor)
        }
    }
}

extension View {
    func withDynamicScaling() -> some View {
        self.modifier(ScalingViewModifier())
    }
}
