import SwiftUI

struct PauseMenuView: View {
    let history: [WordAttempt]
    let quitTitle: String
    let onResume: () -> Void
    let onQuit: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.scalingFactor) var scalingFactor
    @ObservedObject var userSettings = UserSettings.shared
    
    var body: some View {
        ZStack {
            // Darkened background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    onResume()
                }
            
            VStack(spacing: 20 * scalingFactor) {
                // Header
                Text("PAUSED")
                    .font(.custom("DIN Condensed", size: 48 * scalingFactor))
                    .kerning(4)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
                    .padding(.top, 20)
                
                // Content Card
                VStack(spacing: 0) {
                    if history.isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: "pencil.and.list.clipboard")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("No words solved yet")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 40)
                    } else {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Words So Far")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal)
                                .padding(.top, 15)
                                
                            List {
                                ForEach(history.reversed()) { attempt in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(attempt.word.uppercased())
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            
                                            Text(String(format: "%.1fs", attempt.duration))
                                                .font(.caption2)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                        
                                        // Outcome Icon
                                        Group {
                                            switch attempt.outcome {
                                            case .exact:
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                            case .correct:
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            case .skipped:
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                    .listRowBackground(Color.white.opacity(0.1))
                                    .listRowSeparator(.hidden)
                                }
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                        }
                    }
                }
                .frame(maxWidth: 500, maxHeight: 400) // Constrain max size for iPad
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal)
                
                // Handedness Setting
                VStack(spacing: 8) {
                    Text("Handedness")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Picker("Handedness", selection: $userSettings.handedness) {
                        ForEach(Handedness.allCases) { hand in
                            Text(hand.rawValue).tag(hand)
                        }
                    }
                    .pickerStyle(.segmented)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 40)
                .padding(.top, 10)
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: onResume) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Resume")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: 300)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    
                    Button(action: onQuit) {
                        HStack {
                            Image(systemName: "xmark")
                            Text(quitTitle)
                        }
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .frame(maxWidth: 300)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .transition(.opacity)
        .zIndex(100) // Ensure it sits on top
    }
}

#Preview {
    PauseMenuView(
        history: [
            WordAttempt(word: "TEST", duration: 2.5, outcome: .correct),
            WordAttempt(word: "SKIP", duration: 1.0, outcome: .skipped),
            WordAttempt(word: "PERFECT", duration: 5.0, outcome: .exact)
        ],
        quitTitle: "Quit Game",
        onResume: {},
        onQuit: {}
    )
}
