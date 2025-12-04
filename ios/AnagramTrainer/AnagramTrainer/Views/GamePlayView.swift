import SwiftUI
import Combine

struct GamePlayView: View {
    @ObservedObject var viewModel: GameViewModel
    let mode: TrainingMode
    @Environment(\.dismiss) private var dismiss
    @State private var showingResult = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 5) {
                Text(mode.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                
                if mode == .graduated {
                    Text("Level \(viewModel.currentLevel)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else if !mode.hints.isEmpty {
                    Text("Patterns: \(mode.hints)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)
            
            if let state = viewModel.gameState {
                // Scrambled word display
                ScrambledWordView(
                    scrambled: state.scrambledWord,
                    usedPositions: state.usedPositions,
                    onLetterTap: { position, letter in
                        viewModel.addLetter(at: position, letter: letter)
                    }
                )
                .padding(.horizontal)
                
                // Current guess with cursor
                GuessView(
                    guess: state.currentGuess,
                    cursorPosition: state.cursorPosition,
                    isSolved: state.isSolved,
                    onTapPosition: { position in
                        viewModel.setCursor(at: position)
                    }
                )
                .frame(height: 60)
                
                // Timer
                TimerView(startTime: state.startTime)
                
                Spacer()
                
                // Result display
                if state.isComplete {
                    ResultView(
                        word: state.targetWord,
                        solved: state.isSolved,
                        time: state.elapsedTime,
                        definition: viewModel.definition,
                        onNext: {
                            viewModel.resetForNextWord()
                            viewModel.startNewRound(mode: mode)
                        }
                    )
                } else {
                    // Action buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            viewModel.clearGuess()
                        }) {
                            Label("Clear", systemImage: "xmark.circle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            viewModel.submitGuess()
                            if viewModel.gameState?.isComplete ?? false {
                                Task {
                                    await viewModel.fetchDefinition()
                                }
                            }
                        }) {
                            Label("Submit", systemImage: "checkmark.circle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.gradient)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(state.currentGuess.isEmpty)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        viewModel.skipWord()
                    }) {
                        Text("Give Up / Skip")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(.bottom)
                }
            } else {
                ProgressView()
                    .onAppear {
                        viewModel.startNewRound(mode: mode)
                    }
            }
        }
        .navigationTitle(mode.rawValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ScrambledWordView: View {
    let scrambled: String
    let usedPositions: Set<Int>
    let onLetterTap: (Int, Character) -> Void
    
    // Dynamic sizing based on word length
    private var letterSize: CGFloat {
        let length = scrambled.count
        switch length {
        case ...6: return 50
        case 7: return 45
        case 8: return 40
        case 9: return 36
        default: return 32
        }
    }
    
    private var letterSpacing: CGFloat {
        scrambled.count > 7 ? 8 : 12
    }
    
    var body: some View {
        // Use wrapping layout for very long words
        if scrambled.count > 8 {
            VStack(spacing: 12) {
                ForEach(Array(stride(from: 0, to: scrambled.count, by: 5)), id: \.self) { rowStart in
                    HStack(spacing: letterSpacing) {
                        ForEach(rowStart..<min(rowStart + 5, scrambled.count), id: \.self) { index in
                            letterButton(for: Array(scrambled)[index], at: index)
                        }
                    }
                }
            }
        } else {
            HStack(spacing: letterSpacing) {
                ForEach(Array(scrambled.enumerated()), id: \.offset) { index, letter in
                    letterButton(for: letter, at: index)
                }
            }
        }
    }
    
    private func letterButton(for letter: Character, at position: Int) -> some View {
        Button(action: {
            onLetterTap(position, letter)
        }) {
            Text(String(letter).uppercased())
                .font(.system(size: letterSize * 0.6, weight: .bold, design: .rounded))
                .frame(width: letterSize, height: letterSize)
                .background(
                    Circle()
                        .fill(usedPositions.contains(position) ?
                              Color.gray.opacity(0.3) : Color.blue.opacity(0.2))
                )
                .foregroundColor(usedPositions.contains(position) ?
                                .gray : .primary)
        }
        .buttonStyle(.plain)
    }
}

struct TimerView: View {
    let startTime: Date
    @State private var elapsed: TimeInterval = 0
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(String(format: "%.1fs", elapsed))
            .font(.headline)
            .foregroundColor(.secondary)
            .onReceive(timer) { _ in
                elapsed = Date().timeIntervalSince(startTime)
            }
    }
}

struct ResultView: View {
    let word: String
    let solved: Bool
    let time: TimeInterval
    let definition: String
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: solved ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(solved ? .green : .red)
            
            Text(solved ? "Correct!" : "The word was:")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(word.uppercased())
                .font(.title)
                .foregroundColor(.blue)
            
            if solved {
                Text(String(format: "Time: %.1fs", time))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if !definition.isEmpty {
                Text(definition)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Button(action: onNext) {
                Text("Next Word")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.gradient)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
        }
    }
}

struct GuessView: View {
    let guess: String
    let cursorPosition: Int
    let isSolved: Bool
    let onTapPosition: (Int) -> Void
    
    @State private var cursorVisible = true
    
    var body: some View {
        if guess.isEmpty {
            Text("Tap letters or type...")
                .font(.title)
                .foregroundColor(.secondary)
                .onTapGesture {
                    onTapPosition(0)
                }
        } else {
            HStack(spacing: 2) {
                ForEach(Array(guess.enumerated()), id: \.offset) { index, letter in
                    // Cursor before this letter
                    if index == cursorPosition {
                        CursorView(visible: cursorVisible)
                    }
                    
                    // Letter
                    Text(String(letter).uppercased())
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(isSolved ? .green : .primary)
                        .onTapGesture {
                            onTapPosition(index)
                        }
                }
                
                // Cursor at end
                if cursorPosition >= guess.count {
                    CursorView(visible: cursorVisible)
                }
                
                // Tappable area to move cursor to end
                Color.clear
                    .frame(width: 20, height: 30)
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

struct CursorView: View {
    let visible: Bool
    
    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: 2, height: 30)
            .opacity(visible ? 1.0 : 0.2)
    }
}

#Preview {
    NavigationStack {
        GamePlayView(viewModel: GameViewModel(), mode: .random)
    }
}
