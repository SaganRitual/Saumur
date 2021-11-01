// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit

class Layer {
    let mode: Mode
    let parentSKNode: SKNode
    let ringShape: SKShapeNode

    init(scene: ArenaScene, ringRadius: CGFloat) {
        self.mode = .bottom
        self.parentSKNode = scene

        ringShape = SKShapeNode(circleOfRadius: ringRadius)
        ringShape.fillColor = .clear
        ringShape.strokeColor = scene.settings.ringColors[0]

        scene.addChild(ringShape)
    }

    init(mode: Mode, parentLayer: Layer, radius: CGFloat, ringColor: SKColor) {
        self.mode = mode
        self.parentSKNode = parentLayer.ringShape

        ringShape = SKShapeNode(circleOfRadius: radius)
        ringShape.fillColor = .clear
        ringShape.strokeColor = ringColor

        var p0: [CGPoint] = [
            CGPoint(x: -radius, y: 0), CGPoint(x: radius, y: 0)
        ]

        let diameterMarker = SKShapeNode(points: &p0, count: 2)
        let centerMarker = SKShapeNode(circleOfRadius: 10)

        diameterMarker.strokeColor = ringColor; diameterMarker.fillColor = .clear
        centerMarker.strokeColor = ringColor; centerMarker.fillColor = .clear

        ringShape.addChild(diameterMarker)
        ringShape.addChild(centerMarker)

        parentSKNode.addChild(ringShape)
    }
}

extension Layer {
    enum Mode { case bottom, inner, top }
}

class BottomLayer: Layer {
    init(scene: ArenaScene) {
        let unity = 0.95 * scene.frame.width / 2

        super.init(scene: scene, ringRadius: unity)
    }
}

class InnerLayer: Layer {
    let trackShape: SKShapeNode

    init(parentLayer: Layer, settings: Settings, layerIndex: Int) {

        let color: SKColor = settings.showRings ? .blue : .clear

        let parentRadius = parentLayer.ringShape.frame.size.width / 2
        let trackRadius = parentRadius * (1 - settings.ringRadiiFractions[layerIndex])
        let ringRadius = parentRadius - trackRadius

        trackShape = SKShapeNode(circleOfRadius: trackRadius)
        trackShape.fillColor = .clear; trackShape.strokeColor = color; trackShape.zPosition = 5
        trackShape.position = .zero

        super.init(
            mode: .inner, parentLayer: parentLayer,
            radius: ringRadius, ringColor: settings.ringColors[layerIndex]
        )

        ringShape.position = CGPoint(x: trackRadius, y: 0)

        parentSKNode.addChild(trackShape)

        startActions(settings: settings, layerIndex: layerIndex)
    }

    func startActions(settings: Settings, layerIndex: Int) {
        let track0Radius = trackShape.frame.width / 2
        let ring1Radius = ringShape.frame.width / 2
        let ring0Radius = track0Radius + ring1Radius
        let sizeRatio = ring1Radius / ring0Radius

        let orbitDuration = 1 / settings.rotationRateHertz
        let orbit_ = SKAction.follow(trackShape.path!, asOffset: false, orientToPath: false, duration: orbitDuration)
        let orbit = (layerIndex % 1) == 0 ? orbit_ : orbit_.reversed()
        let orbitForever = SKAction.repeatForever(orbit)

        let spinDuration = sizeRatio * orbitDuration
        let spin_ = SKAction.rotate(byAngle: .tau, duration: spinDuration)
        let spin = (layerIndex % 1) == 0 ? spin_.reversed() : spin_
        let spinForever = SKAction.repeatForever(spin)

        let group = SKAction.group([orbitForever, spinForever])
        ringShape.run(group)
    }
}
