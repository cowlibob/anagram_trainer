//
//  ConfettiView.swift
//  AnagramTrainer
//
//  Created by Claude Code on 2026/01/10.
//

import SwiftUI
import SpriteKit
import UIKit

class ConfettiScene: SKScene {
    private var confettiEmitter: SKEmitterNode?

    var baseColor: UIColor = .white
    var colorScheme: ColorScheme = .light

    override func didMove(to view: SKView) {
        setupScene()
        createConfetti()
    }

    private func setupScene() {
        backgroundColor = .clear
        scaleMode = .resizeFill
    }

    private func createConfetti() {
        // Remove existing emitter if any
        confettiEmitter?.removeFromParent()

        let emitter = SKEmitterNode()

        // Position at top center
        emitter.position = CGPoint(x: size.width / 2, y: size.height)
        emitter.zPosition = 100

        // Particle properties
        emitter.particleTexture = createConfettiTexture()
        emitter.particleBirthRate = 10
        emitter.numParticlesToEmit = 0 // Continuous
        emitter.particleLifetime = 8
        emitter.particleLifetimeRange = 2

        // Spawn across the width
        emitter.particlePositionRange = CGVector(dx: size.width, dy: 0)

        // Falling motion
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 50
        emitter.emissionAngle = .pi * 3/2 // Downward
        emitter.emissionAngleRange = .pi / 8

        // Gravity for natural fall
        emitter.yAcceleration = -80

        // Rotation
        emitter.particleRotation = 0
        emitter.particleRotationRange = .pi * 2
        emitter.particleRotationSpeed = 2

        // Size
        emitter.particleSize = CGSize(width: 12, height: 12)
        emitter.particleScaleRange = 0.5
        emitter.particleScaleSpeed = -0.1

        // Color - translucent white
        emitter.particleColor = .white
        emitter.particleColorBlendFactor = 1.0
        emitter.particleAlpha = 0.6
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.1

        // Blend mode for nice overlay effect
        emitter.particleBlendMode = .add

        addChild(emitter)
        confettiEmitter = emitter
    }

    private func createConfettiTexture() -> SKTexture {
        let size = CGSize(width: 12, height: 12)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            // Draw a small rectangle (confetti piece)
            UIColor.white.setFill()
            let rect = CGRect(x: 2, y: 2, width: 8, height: 8)
            context.cgContext.fillEllipse(in: rect)
        }

        return SKTexture(image: image)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        // Update emitter position when size changes
        confettiEmitter?.position = CGPoint(x: size.width / 2, y: size.height)
        confettiEmitter?.particlePositionRange = CGVector(dx: size.width, dy: 0)
    }
}

struct ConfettiView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var scene: ConfettiScene?

    var body: some View {
        GeometryReader { geometry in
            SpriteView(scene: getScene(size: geometry.size), options: [.allowsTransparency])
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
    }

    private func getScene(size: CGSize) -> ConfettiScene {
        if let existingScene = scene {
            return existingScene
        }

        let newScene = ConfettiScene(size: size)
        newScene.colorScheme = colorScheme
        newScene.scaleMode = .resizeFill
        scene = newScene
        return newScene
    }
}

#Preview {
    ZStack {
        LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        ConfettiView()
    }
}
