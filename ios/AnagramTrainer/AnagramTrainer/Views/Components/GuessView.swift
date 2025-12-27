import SwiftUI
import Combine

struct GuessView: View {
    let guess: String
    let cursorPosition: Int
    let isSolved: Bool
    let onTapPosition: (Int) -> Void
    
    @State private var cursorVisible = true
    @Environment(\.scalingFactor) var scalingFactor

    var body: some View {
        if guess.isEmpty {
            Text("Tap letters or type...")
                .font(.system(size: 24 * scalingFactor, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .onTapGesture {
                    onTapPosition(0)
                }
        } else {
            HStack(spacing: 4) {
                // Tappable area to move cursor to beginning
                Color.clear
                    .frame(width: 20, height: 50)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTapPosition(0)
                    }

                ForEach(Array(guess.enumerated()), id: \.offset) { index, letter in
                    // Letter with overlay cursor
                    ZStack(alignment: .leading) {
                        // Cursor before this letter (overlay, no spacing)
                        if index == cursorPosition {
                            CursorView(visible: cursorVisible)
                                .offset(x: -2) // Position at left edge
                        }

                        // Letter
                        Text(String(letter).uppercased())
                            .font(.system(size: 32 * scalingFactor, weight: .bold, design: .rounded))
                            .foregroundColor(isSolved ? .green : .white)
                    }
                    .onTapGesture {
                        onTapPosition(index)
                    }
                }
                
                // Cursor at end (overlay after last letter)
                if cursorPosition >= guess.count {
                    CursorView(visible: cursorVisible)
                }

                // Tappable area to move cursor to end
                Color.clear
                    .frame(width: 20, height: 50)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onTapPosition(guess.count)
                    }
            }
            .onReceive(Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()) { _ in
                cursorVisible.toggle()
            }
        }
    }
}
