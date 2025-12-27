import SwiftUI

struct CampaignResultView: View {
    let word: String
    let solved: Bool
    let points: Int
    let onNext: () -> Void
    @Environment(\.scalingFactor) var scalingFactor

    var body: some View {
        GeometryReader { geometry in
            let isShort = geometry.size.height < 600
            
            ZStack {
                // Transparent background to see through
                Color.clear
                    .background(.ultraThinMaterial.opacity(0.5))
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    
                    // White card overlay
                    VStack(spacing: isShort ? 12 : 24) {
                        if !isShort {
                            Image(systemName: solved ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                                .font(.system(size: 60 * scalingFactor))
                                .foregroundColor(solved ? .green : .orange)
                        }

                        VStack(spacing: 4) {
                            Text(solved ? "Correct!" : "Skipped")
                                .font(isShort ? .subheadline : .title2)
                                .fontWeight(.bold)
                                .foregroundColor(.black)

                            Text(word.uppercased())
                                .font(isShort ? .title : .largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(solved ? .green : Color(red: 1.0, green: 0.3, blue: 0.5))
                        }

                        if solved {
                            Text("+\(points) points")
                                .font(isShort ? .headline : .title)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }

                        Button(action: onNext) {
                            MenuButton(title: "Next Word", icon: isShort ? nil : "arrow.right.circle", color: .orange, isCompact: isShort)
                        }
                        .buttonStyle(.plain)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                        .padding(.bottom, isShort ? 10 : 0)
                    }
                    .padding(isShort ? 20 : 40)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                    )
                    .padding(.horizontal, isShort ? 20 : 40)
                    
                    Spacer()
                }
            }
        }
    }
}
