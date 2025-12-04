import SwiftUI

struct GameResultView: View {
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
            
            if !solved {
                Text(word.uppercased())
                    .font(.title)
                    .foregroundColor(.blue)
            }
            
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
