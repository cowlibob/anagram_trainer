//
//  SpriteMenuBackgroundView.swift
//  AnagramTrainer
//
//  Created by Claude Code on 2026/01/05.
//

import SwiftUI
import SpriteKit

class MenuBackgroundScene: SKScene {
    private var letterNodes: [SKLabelNode] = []
    private let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    var gridSize: Int = 16
    var fontSize: CGFloat = 20.0
    var rotationDuration: TimeInterval = 300.0
    var opacity: CGFloat = 1.0
    var baseColor: UIColor = .red
    var colorScheme: ColorScheme = .light

    override func didMove(to view: SKView) {
        setupScene()
        createLetterGrid()
    }

    private func setupScene() {
        backgroundColor = .clear
        scaleMode = .resizeFill
    }

    private func getRandomLetter() -> String {
        guard let randomChar = alphabet.randomElement() else { return "A" }
        return String(randomChar)
    }

    private func createLetterGrid(orbitDuration: TimeInterval = 30.0) {
        // Remove existing nodes
        letterNodes.forEach { $0.removeFromParent() }
        letterNodes.removeAll()

        guard let view = self.view else { return }

        // Ensure we have valid bounds
        guard view.bounds.width > 0 && view.bounds.height > 0 else { return }

        let centerX = size.width / 2
        let centerY = size.height / 2

        // Calculate diagonal from center to corner (longest distance)
        let diagonal = sqrt(pow(size.width / 2, 2) + pow(size.height / 2, 2))

        // Grid square with sides = 2 * diagonal (covers screen when rotated)
        let gridSize_points = diagonal * 2

        // Calculate spacing for grid
        let cellWidth = gridSize_points / CGFloat(gridSize)
        let cellHeight = gridSize_points / CGFloat(gridSize)

        // 10 rpm = 6 seconds per revolution
//        let orbitDuration: TimeInterval = 6.0

        // Create grid of letters at regular positions
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let letter = getRandomLetter()
                let labelNode = SKLabelNode(fontNamed: "DIN Condensed")
                labelNode.text = letter
                labelNode.fontSize = fontSize
                labelNode.fontColor = getLetterColor().withAlphaComponent(opacity)
                labelNode.verticalAlignmentMode = .center
                labelNode.horizontalAlignmentMode = .center
                labelNode.zPosition = 10

                // Calculate grid position (offset from center to create centered square)
                let gridX = (cellWidth * CGFloat(col) + cellWidth / 2) - gridSize_points / 2 + centerX
                let gridY = (cellHeight * CGFloat(row) + cellHeight / 2) - gridSize_points / 2 + centerY

                // Calculate radius and starting angle from center
                let dx = gridX - centerX
                let dy = gridY - centerY
                let radius = sqrt(dx * dx + dy * dy)
                let startAngle = atan2(dy, dx)

                // Set initial position
                labelNode.position = CGPoint(x: gridX, y: gridY)

                addChild(labelNode)
                letterNodes.append(labelNode)

                // Create clockwise orbital motion
                let orbitAction = SKAction.customAction(withDuration: orbitDuration) { node, elapsedTime in
                    let progress = elapsedTime / CGFloat(orbitDuration)
                    // Clockwise: subtract angle (negative direction)
                    let currentAngle = startAngle - (progress * 2 * .pi)

                    let newX = centerX + cos(currentAngle) * radius
                    let newY = centerY + sin(currentAngle) * radius

                    node.position = CGPoint(x: newX, y: newY)
                }

                let repeatForever = SKAction.repeatForever(orbitAction)
                labelNode.run(repeatForever)
            }
        }
    }

    func updateColors(baseColor: UIColor, colorScheme: ColorScheme) {
        self.baseColor = baseColor
        self.colorScheme = colorScheme

        // Update letter colors
        let letterUIColor = getLetterColor()
        letterNodes.forEach { node in
            node.fontColor = letterUIColor.withAlphaComponent(opacity)
        }
    }

    private func getLetterColor() -> UIColor {
        // Convert to Color, use ThemeManager, then convert back
        let color = Color(baseColor)
        let themeColor = ThemeManager.shared.letterColor(for: color, colorScheme: colorScheme)
        return UIColor(themeColor)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        // Recreate grid when size changes
        createLetterGrid(orbitDuration: rotationDuration)
    }
}

struct SpriteMenuBackgroundView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.themeBaseColor) var envBaseColor
    @Environment(\.themeDarkBaseColor) var envDarkBaseColor

    @State var gridSize: Int = 16
    @State var fontSize: CGFloat = 20.0
    @State var rotationDuration: TimeInterval = 300.0
    @State var opacity: CGFloat = 0.1

    private var currentBase: Color {
        colorScheme == .dark ? envDarkBaseColor : envBaseColor
    }

    private var backgroundGradient: LinearGradient {
        ThemeManager.shared.backgroundGradient(for: currentBase, colorScheme: colorScheme)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient (same as original)
                backgroundGradient
                    .ignoresSafeArea()

                // SpriteKit view with orbiting letters
                SpriteView(scene: createScene(size: geometry.size), options: [.allowsTransparency])
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
            .onChange(of: currentBase) { _, newValue in
                updateSceneColors()
            }
            .onChange(of: colorScheme) { _, _ in
                updateSceneColors()
            }
        }
    }

    private func createScene(size: CGSize) -> MenuBackgroundScene {
        let scene = MenuBackgroundScene(size: size)
        scene.gridSize = gridSize
        scene.fontSize = fontSize
        scene.rotationDuration = rotationDuration
        scene.opacity = opacity
        scene.baseColor = UIColor(currentBase)
        scene.colorScheme = colorScheme
        scene.scaleMode = .resizeFill
        return scene
    }

    private func updateSceneColors() {
        // This will be handled by the scene's update method
        // For now, we rely on the scene recreating when the view updates
    }
}

#Preview {
    SpriteMenuBackgroundView()
        .environment(\.themeBaseColor, .red)
        .environment(\.themeDarkBaseColor, .red)
}
