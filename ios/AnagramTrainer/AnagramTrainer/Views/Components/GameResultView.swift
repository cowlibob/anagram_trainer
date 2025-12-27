import SwiftUI

struct GameResultView: View {
    let word: String
    let solved: Bool
    let time: TimeInterval
    let definition: String
    let onNext: () -> Void

    @Environment(\.scalingFactor) var scalingFactor
    
    var body: some View {
        GeometryReader { geometry in
            let isShort = geometry.size.height < 600
            
            VStack {
                Spacer()
                
                VStack(spacing: isShort ? 12 : 24) {
                    if !isShort {
                        Image(systemName: solved ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                            .font(.system(size: 60 * scalingFactor))
                            .foregroundColor(solved ? .green : .orange)
                    }

                    VStack(spacing: 4) {
                        Text(solved ? "Correct!" : "The word was:")
                            .font(isShort ? .subheadline : .title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)

                        Text(word.uppercased())
                            .font(isShort ? .title : .largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(solved ? .green : Color(red: 1.0, green: 0.3, blue: 0.5))
                        
                        if solved && isShort {
                            Text(String(format: "Time: %.1fs", time))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    if solved && !isShort {
                        Text(String(format: "Time: %.1fs", time))
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }

                    VStack {
                        if definition.isEmpty {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .tint(.secondary)
                                Text("Fetching definition...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            ScrollView {
                                Text(definition)
                                    .font(isShort ? .subheadline : .body)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .padding(isShort ? 10 : 20)
                            }
                        }
                    }
                    .frame(height: isShort ? 80 : 150) // Reduced height for short windows
                    .background(Color.primary.opacity(0.03))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    Button(action: onNext) {
                        MenuButton(title: "Next Word", icon: isShort ? nil : "arrow.right.circle", color: .blue, isCompact: isShort)
                    }
                    .buttonStyle(.plain)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                    .padding(.bottom, isShort ? 10 : 0)
                }
                .padding(isShort ? 20 : 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, isShort ? 20 : 40)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
