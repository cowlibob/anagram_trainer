//
//  MenuBackgroundView.swift
//  AnagramTrainer
//
//  Created by James Cowlishaw on 2024/11/24.
//

import SwiftUI
import Combine

class MenuBackgroundViewModel: ObservableObject {
    @Published private(set) var letters: [[String]] = []
    private var allLetters: [String] = []
    private var currentIndex = 0
    var gridSize = 16

    init() {
        loadDictionary()
        generateLetters()
    }

    private func loadDictionary() {
        guard let path = Bundle.main.path(forResource: "dictionary", ofType: "txt"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return
        }

        let words = content.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }

        // Extract all letters from all words and shuffle
        var letters: [String] = []
        for word in words {
            letters.append(contentsOf: word.uppercased().map { String($0) })
        }

        allLetters = letters.shuffled()
    }

    private func generateLetters() {
        var grid: [[String]] = []

        for _ in 0..<gridSize {
            var row: [String] = []
            for _ in 0..<gridSize {
                row.append(getNextLetter())
            }
            grid.append(row)
        }

        letters = grid
    }

    private func getNextLetter() -> String {
        guard !allLetters.isEmpty else { return "A" }

        let letter = allLetters[currentIndex % allLetters.count]
        currentIndex += 1
        return letter
    }

    func refreshLetters() {
        generateLetters()
    }
}

struct MenuBackgroundView: View {
    @StateObject private var viewModel = MenuBackgroundViewModel()
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeBaseColor) var envBaseColor
    @Environment(\.themeDarkBaseColor) var envDarkBaseColor

    @State var gridSize: Int = 16
    @State var gap: CGFloat = 1.0
    @State var scale: CGFloat = 1.0
    @State var fontSize: CGFloat = 1.0
    @State var rotationDuration: TimeInterval = 10.0
    @State private var rotationDegrees = -360.0
    @State var opacity = 0.1
    
    private var rotateAnimation: Animation {
        .linear(duration: rotationDuration)
        .repeatForever(autoreverses: false)
    }

    private var currentBase: Color {
        colorScheme == .dark ? envDarkBaseColor : envBaseColor
    }

    private var backgroundGradient: LinearGradient {
        ThemeManager.shared.backgroundGradient(for: currentBase, colorScheme: colorScheme)
    }

    private var letterColor: Color {
        ThemeManager.shared.letterColor(for: currentBase, colorScheme: colorScheme)
    }

    var body: some View {
        GeometryReader { geometry in
            let cellSize = max(geometry.size.width, geometry.size.height) / CGFloat(gridSize)
            let scaledFontSize = cellSize * fontSize
            
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(0..<gridSize, id: \.self) { y in
                    GridRow {
                        ForEach(0..<gridSize, id: \.self) { x in
                            Text(viewModel.letters[y][x])
                                .font(.custom("DIN Condensed", size: scaledFontSize))
                                .minimumScaleFactor(0.1)
                                .foregroundStyle(letterColor)
                                .baselineOffset(-fontSize * 2)
                                .frame(minWidth: cellSize, minHeight: cellSize)
                                .padding(gap)
                                .rotationEffect(.degrees(rotationDegrees))
                        }
                    }
                }
            }
            .opacity(opacity) // Apply opacity to the letter grid ONLY
            .rotationEffect(.degrees(-rotationDegrees))
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                viewModel.gridSize = gridSize
                withAnimation(rotateAnimation) {
                    rotationDegrees = 0.0
                }
            }
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    MenuBackgroundView()
        .clipped()
}
