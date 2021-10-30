// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit
import SwiftUI

class Ring {
    let penNode: SKShapeNode?
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
        radiusFraction = 1
        trackPath = nil
    }

    init(
        scene: ArenaScene, parentRadius: Double,
        radiusFraction: Double, isTopRing: Bool = false
    ) {
        self.radiusFraction = radiusFraction

        let radius = parentRadius * radiusFraction
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
        trackNodeOnlyForDebug.strokeColor = .clear
        trackNodeOnlyForDebug.position = .zero

        scene.nRing0!.shapeNode.addChild(trackNodeOnlyForDebug)
        #endif

        guard isTopRing else { penNode = nil; return }

        var penPoints: [CGPoint] = [
            .zero, CGPoint(x: scene.settings.penLengthFraction * radius, y: 0)
        ]

        penNode = SKShapeNode(points: &penPoints, count: 2)
        penNode!.lineWidth = Settings.ringLineWidth
        penNode!.fillColor = .green
        penNode!.strokeColor = .red
        penNode!.position = .zero

        shapeNode.addChild(penNode!)
    }
}
