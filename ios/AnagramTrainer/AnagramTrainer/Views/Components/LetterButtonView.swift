import SwiftUI

struct LetterButtonView: View {
    let letter: Character
    let isUsed: Bool
    let isHint: Bool
    let size: CGFloat
    let onTap: () -> Void
    
    @State private var bounceAnimation = false
    
    var body: some View {
        Button(action: onTap) {
            Text(String(letter).uppercased())
                .font(.system(size: size * 0.7, weight: .bold, design: .rounded))
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(isUsed ?
                              Color.white.opacity(0.15) : Color.white.opacity(0.3))
                )
                .foregroundColor(isUsed ? Color.white.opacity(0.3) : .white)
        }
        .buttonStyle(.plain)
        .scaleEffect(isHint && bounceAnimation ? 1.2 : 1.0)
        .animation(
            isHint ? Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .default,
            value: bounceAnimation
        )
        .onAppear {
            if isHint {
                bounceAnimation = true
            }
        }
    }
}
