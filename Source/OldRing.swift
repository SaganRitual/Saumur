// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit
import SwiftUI

class OldRing {
    let penNode: SKShapeNode?
    let radius: CGFloat
    let radiusFraction: Double
    let shapeNode: SKShapeNode
    let trackPath: CGMutablePath?

    // Ring 0 has only the shape node
    init(scene: ArenaScene) {
        shapeNode = SKShapeNode(circleOfRadius: 0.95 * scene.frame.width / 2)
        shapeNode.lineWidth = Settings.ringLineWidth
        shapeNode.fillColor = .clear
        shapeNode.strokeColor = .darkGray
        shapeNode.position = CGPoint.zero

        penNode = nil
        radius = scene.radiusOf(ring: shapeNode)
        radiusFraction = 1
        trackPath = nil
    }

    init(scene: ArenaScene, ringIndex: Int) {
        let parentRadius = scene.shapeNodeRadius(ring: ringIndex - 1)

        self.radiusFraction = scene.settings.ringRadiiFractions[ringIndex]
        self.radius = parentRadius * self.radiusFraction

        let trackRadius = parentRadius * (1 - radiusFraction)

        shapeNode = SKShapeNode(circleOfRadius: radius)
        shapeNode.lineWidth = Settings.ringLineWidth
        shapeNode.fillColor = .clear
        shapeNode.strokeColor = .darkGray
        shapeNode.position = CGPoint(x: trackRadius, y: 0)

        let trackPathFrameSize = CGSize(width: trackRadius * 2, height: trackRadius * 2)
        let trackRect = CGRect(origin: CGPoint(x: -trackRadius, y: -trackRadius), size: trackPathFrameSize)
        trackPath = CGMutablePath(ellipseIn: trackRect, transform: nil)

        #if DEBUG
        let trackNodeOnlyForDebug = SKShapeNode(circleOfRadius: trackRadius)
        trackNodeOnlyForDebug.lineWidth = Settings.ringLineWidth
        trackNodeOnlyForDebug.fillColor = .clear
        trackNodeOnlyForDebug.strokeColor = .blue
        trackNodeOnlyForDebug.position = .zero

        scene.ringShapes[ringIndex - 1].addChild(trackNodeOnlyForDebug)
        #endif

        if ringIndex < scene.ringShapes.count - 1 { penNode = nil; return }

        var penPoints: [CGPoint] = [
            .zero,
            CGPoint(x: +scene.settings.penLengthFraction * radius, y: 0)
        ]

        penNode = SKShapeNode(points: &penPoints, count: 2)
        penNode!.lineWidth = Settings.ringLineWidth
        penNode!.fillColor = .green
        penNode!.strokeColor = .red
        penNode!.position = .zero

        shapeNode.addChild(penNode!)
    }
}
