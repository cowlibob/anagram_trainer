import SwiftUI
import Combine

struct TimerView: View {
    let startTime: Date
    let endTime: Date?
    var isPaused: Bool = false
    @State private var elapsed: TimeInterval = 0
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(formattedTime)
            .font(.system(size: 20, weight: .semibold, design: .rounded).monospacedDigit())
            .italic()
            .foregroundColor(.white.opacity(0.5))
            .onReceive(timer) { _ in
                guard !isPaused else { return }
                if let end = endTime {
                    elapsed = end.timeIntervalSince(startTime)
                } else {
                    elapsed = Date().timeIntervalSince(startTime)
                }
            }
            .onAppear {
                if let end = endTime {
                    elapsed = end.timeIntervalSince(startTime)
                } else {
                    elapsed = Date().timeIntervalSince(startTime)
                }
            }
    }

    private var formattedTime: String {
        let seconds = Int(elapsed)
        let decimal = Int((elapsed - Double(seconds)) * 10)
        return String(format: "%02d.%01ds", seconds, decimal)
    }
}
