import SwiftUI

struct CampaignResultView: View {
    let word: String
    let solved: Bool
    let points: Int
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: solved ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(solved ? .green : .red)
            
            Text(solved ? "Correct!" : "Skipped")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(word.uppercased())
                .font(.title)
                .foregroundColor(.blue)
            
            if solved {
                Text("+\(points) points")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            Button(action: onNext) {
                Text("Next Word")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.gradient)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
        }
    }
}
