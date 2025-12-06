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
            print("Failed to load dictionary.txt")
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

    @State var scale: CGFloat = 1.0
    @State private var rotationDegrees = -45.0
    private var rotateAnimation: Animation {
        .easeInOut(duration: 10.0)
        .repeatForever(autoreverses: true)
    }

    var body: some View {
        GeometryReader { geometry in
            let cellSize = max(geometry.size.width, geometry.size.height) / (10 * scale)
            let fontSize = cellSize * 0.75

            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(0..<viewModel.gridSize, id: \.self) { y in
                    GridRow {
                        ForEach(0..<viewModel.gridSize, id: \.self) { x in
                            Button {

                            } label: {
                                Text(viewModel.letters.indices.contains(y) && viewModel.letters[y].indices.contains(x)
                                     ? viewModel.letters[y][x]
                                     : "")
                                    .minimumScaleFactor(0.1)
                                    .lineLimit(1)
                                    .allowsTightening(true)
                            }
                            .frame(minWidth: cellSize, minHeight: cellSize)
                            .font(.custom("DIN Condensed", size: fontSize))
                            .foregroundStyle(.white.opacity(0.1))
                            .rotationEffect(.degrees(rotationDegrees))
                            .opacity(opacity(x: x, y: y))
                        }
                    }
                }
            }
            .rotationEffect(.degrees(-rotationDegrees))
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                print("scale: \(scale), cellSize: \(cellSize)")
                withAnimation(rotateAnimation) {
                    rotationDegrees = 45.0
                }
            }
        }
    }

    private func opacity(x: Int, y: Int) -> Double {
        let half = 3.0
        return pow(Double(y) - half, 2) + pow(Double(x) - half, 2)
    }
}

#Preview {
    MenuBackgroundView()
        .clipped()
}
