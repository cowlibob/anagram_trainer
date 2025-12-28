import SwiftUI

struct TrainingMenuView: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var theme = ThemeManager.shared
    @Environment(\.colorScheme) var colorScheme

    private let trainingModes: [TrainingMode] = [
        .graduated, .suffix, .prefix,
        .vowelCluster, .consonantBlend, .digraph, .trigraph
    ]

    @Environment(\.scalingFactor) var scalingFactor
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    // Local animation state
    @State private var animatedBase: Color? = nil
    
    private var currentBase: Color {
        animatedBase ?? .purple
    }

    var body: some View {
        ZStack {
            MenuBackgroundView(
                gridSize: 10,
                gap: 10.0 * scalingFactor,
                scale: 1.0,
                fontSize: 8.0,
                rotationDuration: 30.0
            )
            .background(ThemeManager.shared.backgroundGradient(for: currentBase, colorScheme: colorScheme))
            .ignoresSafeArea()

            ScrollView {
                Group {
                    if horizontalSizeClass == .regular {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            trainingButtons
                        }
                    } else {
                        VStack(spacing: 20) {
                            trainingButtons
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .environment(\.themeBaseColor, currentBase)
        .environment(\.themeDarkBaseColor, currentBase) // Training uses purple for both for consistency
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .tint(.white)
    }

    @ViewBuilder
    private var trainingButtons: some View {
        ForEach(trainingModes) { mode in
            if mode == .graduated {
                themeAnimatedNavigationLink(
                    destination: GraduatedDifficultySelector(viewModel: viewModel),
                    title: mode.rawValue,
                    icon: mode.icon,
                    accentColor: mode.color
                )
            } else {
                themeAnimatedNavigationLink(
                    destination: GamePlayView(viewModel: viewModel, mode: mode),
                    title: mode.rawValue,
                    icon: mode.icon,
                    accentColor: mode.color
                )
            }
        }

    }

    @ViewBuilder
    private func themeAnimatedNavigationLink<V: View>(
        destination: V,
        title: String,
        icon: String,
        accentColor: Color
    ) -> some View {
        NavigationLink(destination: destination) {
            MenuButton(
                title: title,
                icon: icon,
                color: accentColor,
                textColor: .white
            )
        }
        .buttonStyle(PressedButtonStyle(onPressing: { isPressed in
            withAnimation(.easeInOut(duration: 0.4)) {
                animatedBase = isPressed ? accentColor : nil
            }
        }))
    }
}

#Preview {
    NavigationStack {
        TrainingMenuView(viewModel: GameViewModel())
    }
}
