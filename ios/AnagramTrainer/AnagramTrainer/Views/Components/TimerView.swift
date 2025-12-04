import SwiftUI
import Combine

struct TimerView: View {
    let startTime: Date
    let endTime: Date?
    @State private var elapsed: TimeInterval = 0
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(String(format: "%.1fs", elapsed))
            .font(.headline)
            .foregroundColor(.secondary)
            .onReceive(timer) { _ in
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
}
