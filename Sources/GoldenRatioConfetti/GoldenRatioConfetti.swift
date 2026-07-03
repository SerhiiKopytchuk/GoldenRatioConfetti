//
//  GoldenRatioConfetti.swift
//  Created by Serhii Kopytchuk on 04.07.2026.
//

import Foundation
import SpriteKit
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public struct GoldenRatioConfetti: View {

    private static let particleNames = (1...6).map { "Particle_\($0)" }
    @MainActor private static let particleTextures = particleNames.map {
        makeParticleTexture(named: $0)
    }

    private static let visibleHeightRatio: CGFloat = 0.8
    private static let delay: TimeInterval = 0.35
    private static let spawnDuration: TimeInterval = 0.9
    private static let bottomFadeHeight: CGFloat = 50

    private static let particleCount = 56
    private static let goldenRatio: CGFloat = 1.61803398875

    private static let spiralDuration: TimeInterval = 3.4
    private static let gravityDurationRange: ClosedRange<Double> = 0.9...1.45

    private static let spiralQuarterTurns: CGFloat = 4
    private static let spiralWidthRatio: CGFloat = 0.8
    private static let spiralHeightRatio: CGFloat = 0.7
    private static let horizontalPadding: CGFloat = 28

    private static let startSpread: CGFloat = 150
    private static let endSpread: CGFloat = 430
    private static let verticalSpreadRatio: CGFloat = 0.50

    public init() {}

    private struct SpiralLayout {
        let topY: CGFloat
        let scaleX: CGFloat
        let scaleY: CGFloat
        let leftBound: CGFloat
        let rightBound: CGFloat
    }

    private struct SpiralMotion {
        let spreadX: CGFloat
        let spreadY: CGFloat
        let angleDrift: CGFloat
        let radiusDrift: CGFloat
        let progressPower: CGFloat
        let wavePhase: CGFloat
        let waveFrequency: CGFloat
        let horizontalWave: CGFloat
        let verticalWave: CGFloat
        let endSpreadMultiplier: CGFloat
        let verticalEndSpreadMultiplier: CGFloat
    }

    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let visibleHeight = size.height * Self.visibleHeightRatio

            SpriteView(
                scene: makeScene(
                    size: size,
                    visibleHeight: visibleHeight
                ),
                options: [.allowsTransparency]
            )
            .frame(maxWidth: .infinity)
            .frame(height: visibleHeight, alignment: .top)
            .mask(confettiMask(visibleHeight: visibleHeight))
            .allowsHitTesting(false)
            .ignoresSafeArea()
        }
    }

    private func confettiMask(visibleHeight: CGFloat) -> some View {
        let fadeStart = max(0, (visibleHeight - Self.bottomFadeHeight) / visibleHeight)

        return LinearGradient(
            stops: [
                .init(color: .white, location: 0),
                .init(color: .white, location: fadeStart),
                .init(color: .clear, location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func makeScene(
        size: CGSize,
        visibleHeight: CGFloat
    ) -> SKScene {
        let scene = SKScene(size: size)
        scene.scaleMode = .resizeFill
        scene.backgroundColor = .clear
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        runAnimation(
            in: scene,
            size: size,
            visibleHeight: visibleHeight
        )

        return scene
    }

    private func runAnimation(
        in scene: SKScene,
        size: CGSize,
        visibleHeight: CGFloat
    ) {
        for index in 0..<Self.particleCount {
            let spawnDelay = Self.delay
                + Double(index) / Double(Self.particleCount) * Self.spawnDuration

            scene.run(.sequence([
                .wait(forDuration: spawnDelay),
                .run { [weak scene] in
                    guard let scene else { return }

                    let particle = makeParticleNode(
                        index: index,
                        size: size,
                        visibleHeight: visibleHeight
                    )

                    scene.addChild(particle)
                },
            ]))
        }
    }

    private func makeParticleNode(
        index: Int,
        size: CGSize,
        visibleHeight: CGFloat
    ) -> SKSpriteNode {
        let texture = Self.particleTextures[index % Self.particleTextures.count]
        let particle = SKSpriteNode(texture: texture)

        let layout = spiralLayout(
            size: size,
            visibleHeight: visibleHeight
        )

        let depth = CGFloat.random(in: 0...1)
        let scale = 0.08 + depth * 0.11
        let motion = makeSpiralMotion()

        particle.position = spiralPosition(
            progress: 0,
            layout: layout,
            motion: motion
        )

        particle.setScale(scale)
        particle.alpha = 0.7 + depth * 0.3
        particle.zPosition = depth * 1000
        particle.zRotation = CGFloat.random(in: -.pi ... .pi)
        particle.blendMode = .alpha

        particle.run(
            makeSpiralAction(
                layout: layout,
                motion: motion,
                direction: index.isMultiple(of: 2) ? 1 : -1,
                depth: depth
            )
        )

        return particle
    }

    private func makeSpiralAction(
        layout: SpiralLayout,
        motion: SpiralMotion,
        direction: CGFloat,
        depth: CGFloat
    ) -> SKAction {
        let spiralDuration = Self.spiralDuration
            + Double.random(in: -0.25...0.35)
            - Double(depth) * 0.3

        let gravityDuration = Double.random(in: Self.gravityDurationRange)
        let gravityDistance = CGFloat.random(in: 180...340) + depth * 90
        let gravityDrift = CGFloat.random(in: -44...44)

        let rotationStart = CGFloat.random(in: -.pi ... .pi)
        let rotationMiddle = rotationStart
            + direction * CGFloat.random(in: .pi * 1.4 ... .pi * 2.6)

        let rotationEnd = rotationMiddle
            + direction * CGFloat.random(in: .pi * 0.6 ... .pi * 1.4)

        let flutterCycles = CGFloat.random(in: 2.2...4.0)
        let flutterAmount = CGFloat.random(in: 0.12...0.34)
        let phase = CGFloat.random(in: 0...(.pi * 2))

        var gravityStartPosition: CGPoint = .zero

        return .sequence([
            .customAction(withDuration: spiralDuration) { node, elapsedTime in
                let rawProgress = min(1, elapsedTime / CGFloat(spiralDuration))
                let progress = easeOutQuad(rawProgress)

                node.position = spiralPosition(
                    progress: progress,
                    layout: layout,
                    motion: motion
                )

                let flutter = sine(
                    phase + rawProgress * .pi * 2 * flutterCycles
                ) * flutterAmount

                node.alpha = 1
                node.zRotation = rotationStart
                    + (rotationMiddle - rotationStart) * rawProgress
                    + flutter

                gravityStartPosition = node.position
            },

            .customAction(withDuration: gravityDuration) { node, elapsedTime in
                let rawProgress = min(1, elapsedTime / CGFloat(gravityDuration))
                let gravityProgress = easeInQuad(rawProgress)

                let xPosition = gravityStartPosition.x + gravityDrift * rawProgress
                let yPosition = gravityStartPosition.y - gravityDistance * gravityProgress

                let flutter = sine(
                    phase * 1.4 + rawProgress * .pi * 2 * 2.2
                ) * flutterAmount * (1 - rawProgress)

                node.position = CGPoint(x: xPosition, y: yPosition)

                node.zRotation = rotationMiddle
                    + (rotationEnd - rotationMiddle) * rawProgress
                    + flutter

                node.alpha = 1 - easeInQuad(rawProgress)
            },

            .removeFromParent(),
        ])
    }

    private func spiralPosition(
        progress: CGFloat,
        layout: SpiralLayout,
        motion: SpiralMotion
    ) -> CGPoint {
        let pathProgress = pow(progress, motion.progressPower)

        let theta = .pi / 2 * Self.spiralQuarterTurns * pathProgress
        let angle = .pi / 2 - theta + motion.angleDrift * progress

        let radiusScale = spiralRadiusScale(theta: theta)
        let radiusDrift = 1 + motion.radiusDrift * progress

        let normalizedX = cosine(angle) * radiusScale * radiusDrift
        let normalizedY = sine(angle) * radiusScale * radiusDrift

        let targetEndSpread = Self.endSpread * motion.endSpreadMultiplier

        let currentSpread = Self.startSpread
            + (targetEndSpread - Self.startSpread) * progress

        let waveAngle = .pi * 2 * motion.waveFrequency * progress + motion.wavePhase

        let horizontalSpread = motion.spreadX * currentSpread / 2

        let verticalSpread = motion.spreadY
            * currentSpread
            * Self.verticalSpreadRatio
            * motion.verticalEndSpreadMultiplier
            * progress

        let horizontalWave = sine(waveAngle) * motion.horizontalWave * progress
        let verticalWave = cosine(waveAngle) * motion.verticalWave * progress

        let xPosition = clamped(
            normalizedX * layout.scaleX + horizontalSpread + horizontalWave,
            minimum: layout.leftBound,
            maximum: layout.rightBound
        )

        let yPosition = layout.topY
            + (normalizedY - 1) * layout.scaleY
            + verticalSpread
            + verticalWave

        return CGPoint(x: xPosition, y: yPosition)
    }

    private func makeSpiralMotion() -> SpiralMotion {
        SpiralMotion(
            spreadX: CGFloat.random(in: -1...1),
            spreadY: CGFloat.random(in: -1...1),
            angleDrift: CGFloat.random(in: -0.24...0.24),
            radiusDrift: CGFloat.random(in: -0.14...0.16),
            progressPower: CGFloat.random(in: 0.86...1.18),
            wavePhase: CGFloat.random(in: 0...(.pi * 2)),
            waveFrequency: CGFloat.random(in: 1.1...2.4),
            horizontalWave: CGFloat.random(in: 12...44),
            verticalWave: CGFloat.random(in: 8...30),
            endSpreadMultiplier: CGFloat.random(in: 0.75...1.35),
            verticalEndSpreadMultiplier: CGFloat.random(in: 0.65...1.45)
        )
    }

    private func spiralLayout(
        size: CGSize,
        visibleHeight: CGFloat
    ) -> SpiralLayout {
        let halfWidth = size.width / 2

        let leftBound = -halfWidth + Self.horizontalPadding
        let rightBound = halfWidth - Self.horizontalPadding
        let availableWidth = rightBound - leftBound

        let targetWidth = min(
            max(120, size.width * Self.spiralWidthRatio - Self.endSpread),
            availableWidth
        )

        let targetHeight = min(
            size.height * Self.spiralHeightRatio,
            visibleHeight - Self.bottomFadeHeight - 16
        )

        let normalizedWidth = spiralNormalizedXMax - spiralNormalizedXMin
        let normalizedHeight = spiralNormalizedYMax - spiralNormalizedYMin

        return SpiralLayout(
            topY: visibleHeight / 2 - 8,
            scaleX: targetWidth / normalizedWidth,
            scaleY: targetHeight / normalizedHeight,
            leftBound: leftBound,
            rightBound: rightBound
        )
    }

    private var spiralNormalizedXMin: CGFloat {
        -1 / pow(Self.goldenRatio, 3)
    }

    private var spiralNormalizedXMax: CGFloat {
        1 / Self.goldenRatio
    }

    private var spiralNormalizedYMin: CGFloat {
        -1 / pow(Self.goldenRatio, 2)
    }

    private var spiralNormalizedYMax: CGFloat {
        1
    }

    private func spiralRadiusScale(theta: CGFloat) -> CGFloat {
        let quarterTurns = theta / (.pi / 2)
        return CGFloat(pow(Double(Self.goldenRatio), -Double(quarterTurns)))
    }

    private static func makeParticleTexture(named name: String) -> SKTexture {
        guard let url = Bundle.module.url(
            forResource: name,
            withExtension: "png",
            subdirectory: "Particles"
        ) else {
            preconditionFailure("GoldenRatioConfetti is missing bundled particle resource: \(name).png")
        }

        #if canImport(UIKit)
        guard
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data)
        else {
            preconditionFailure("GoldenRatioConfetti could not load bundled particle resource: \(name).png")
        }

        return SKTexture(image: image)
        #elseif canImport(AppKit)
        guard let image = NSImage(contentsOf: url) else {
            preconditionFailure("GoldenRatioConfetti could not load bundled particle resource: \(name).png")
        }

        return SKTexture(image: image)
        #endif
    }

    private func clamped(
        _ value: CGFloat,
        minimum: CGFloat,
        maximum: CGFloat
    ) -> CGFloat {
        min(max(value, minimum), maximum)
    }

    private func sine(_ angle: CGFloat) -> CGFloat {
        CGFloat(sin(Double(angle)))
    }

    private func cosine(_ angle: CGFloat) -> CGFloat {
        CGFloat(cos(Double(angle)))
    }

    private func easeOutQuad(_ progress: CGFloat) -> CGFloat {
        1 - (1 - progress) * (1 - progress)
    }

    private func easeInQuad(_ progress: CGFloat) -> CGFloat {
        progress * progress
    }
}
