import SwiftUI

struct TrainingMenuView: View {
    @ObservedObject var viewModel: GameViewModel

    private let trainingModes: [TrainingMode] = [
        .graduated, .suffix, .prefix,
        .vowelCluster, .consonantBlend, .digraph, .trigraph
    ]

    private func icon(for mode: TrainingMode) -> String {
        switch mode {
        case .random: return "shuffle"
        case .graduated: return "chart.bar"
        case .suffix: return "arrow.right.to.line"
        case .prefix: return "arrow.left.to.line"
        case .digraph: return "2.circle"
        case .vowelCluster: return "a.circle"
        case .consonantBlend: return "b.circle"
        case .trigraph: return "3.circle"
        }
    }

    private func color(for mode: TrainingMode) -> Color {
        switch mode {
        case .random: return .cyan
        case .graduated: return .green
        case .suffix: return .orange
        case .prefix: return .blue
        case .digraph: return .purple
        case .vowelCluster: return .pink
        case .consonantBlend: return .teal
        case .trigraph: return .indigo
        }
    }

    var body: some View {
        ZStack {
            MenuBackgroundView(
                gridSize: 10,
                gap: 50.0,
                scale: 1.0,
                fontSize: 8.0,
                rotationDuration: 30.0
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(trainingModes) { mode in
                        if mode == .graduated {
                            NavigationLink(destination: GraduatedDifficultySelector(viewModel: viewModel)) {
                                TrainingModeButton(
                                    title: mode.rawValue,
                                    icon: icon(for: mode),
                                    color: color(for: mode)
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
                            NavigationLink(destination: GamePlayView(viewModel: viewModel, mode: mode)) {
                                TrainingModeButton(
                                    title: mode.rawValue,
                                    icon: icon(for: mode),
                                    color: color(for: mode)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
    }
}

struct TrainingModeButton: View {
    let title: String
    let icon: String
    let color: Color
    var badge: String? = nil
    let fontSize = 32.0

    private var isLargeDevice: Bool {
        UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac
    }

    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.custom("Din", size: fontSize))
                .padding(.leading, 32)

            Text(title)
                .font(.custom("Din", size: fontSize))
                .padding(.leading, 64)

            Spacer()
        }
        .foregroundColor(.white)
        .padding()
        .padding(.vertical, isLargeDevice ? 16 : 0)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(color.opacity(0.3))
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            }
        )
        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    NavigationStack {
        TrainingMenuView(viewModel: GameViewModel())
    }
}
