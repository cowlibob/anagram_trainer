import SwiftUI

struct CursorView: View {
    let visible: Bool
    
    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: 4, height: 30)
            .opacity(visible ? 1.0 : 0.2)
    }
}
