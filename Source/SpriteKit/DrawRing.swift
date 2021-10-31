// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit

enum DrawRing {
    static var ringShapes = [SKShapeNode]()
    static var penShape: SKShapeNode!

    static func drawRing0(scene: ArenaScene) {
        let color: SKColor = scene.settings.showRings ? .cyan : .clear

        let unity = 0.95 * scene.frame.width / 2
        let r0 = SKShapeNode(circleOfRadius: unity * scene.settings.ringRadiiFractions[0])
        r0.strokeColor = color; r0.fillColor = .clear

        ringShapes.append(r0)

        var p0: [CGPoint] = [
            CGPoint(x: -unity, y: 0), CGPoint(x: unity, y: 0)
        ]

        let L0 = SKShapeNode(points: &p0, count: 2)
        let C0 = SKShapeNode(circleOfRadius: 10)
        L0.strokeColor = color; L0.fillColor = color
        C0.strokeColor = color; C0.fillColor = .clear
        r0.addChild(L0)
        r0.addChild(C0)

        scene.addChild(r0)
    }

    static func drawTrack0(scene: ArenaScene, ring0: SKShapeNode) -> SKShapeNode {
        let color: SKColor = scene.settings.showRings ? .blue : .clear

        let track0Radius = ring0.frame.width / 2 * (1 - scene.settings.ringRadiiFractions[1])
        let track0 = SKShapeNode(circleOfRadius: track0Radius)
        track0.fillColor = .clear; track0.strokeColor = color; track0.zPosition = 5
        track0.position = .zero

        ring0.addChild(track0)
        return track0
    }

    static func drawRing1(scene: ArenaScene, ring0: SKShapeNode) -> SKShapeNode {
        let color: SKColor = scene.settings.showRings ? .magenta : .clear

        let track0Radius = ring0.frame.width / 2 * (1 - scene.settings.ringRadiiFractions[1])
        let ring1Radius = ring0.frame.width / 2 * scene.settings.ringRadiiFractions[1]

        let ring1 = SKShapeNode(circleOfRadius: ring1Radius)
        ring1.fillColor = .clear; ring1.strokeColor = color; ring1.zPosition = 5
        ring1.position = CGPoint(x: track0Radius, y: 0)

        var p1: [CGPoint] = [
            CGPoint(x: -ring1Radius, y: 0),
            CGPoint(x: +ring1Radius, y: 0)
        ]

        let L1 = SKShapeNode(points: &p1, count: 2)
        let C1 = SKShapeNode(circleOfRadius: 10)
        L1.strokeColor = color; L1.fillColor = .clear
        C1.strokeColor = color; C1.fillColor = .clear

        ring1.addChild(L1)
        ring1.addChild(C1)

        ring0.addChild(ring1)
        ringShapes.append(ring1)
        return ring1
    }

    static func drawTrack1(scene: ArenaScene, ring1: SKShapeNode) -> SKShapeNode {
        let color: SKColor = scene.settings.showRings ? .blue : .clear

        let track1Radius = ring1.frame.width / 2 * (1 - scene.settings.ringRadiiFractions[2])
        let track1 = SKShapeNode(circleOfRadius: track1Radius)
        track1.fillColor = .clear; track1.strokeColor = color; track1.zPosition = 5
        track1.position = .zero

        ring1.addChild(track1)
        return track1
    }

    static func drawRing2(scene: ArenaScene, ring1: SKShapeNode) -> SKShapeNode {
        let color: SKColor = scene.settings.showRings ? .yellow : .clear

        let track1Radius = ring1.frame.width / 2 * (1 - scene.settings.ringRadiiFractions[2])
        let ring2Radius = ring1.frame.width / 2 * scene.settings.ringRadiiFractions[2]

        let ring2 = SKShapeNode(circleOfRadius: ring2Radius)
        ring2.fillColor = .clear; ring2.strokeColor = color; ring2.zPosition = 5
        ring2.position = CGPoint(x: track1Radius, y: 0)

        var p2: [CGPoint] = [
            CGPoint(x: -ring2Radius, y: 0),
            CGPoint(x: +ring2Radius, y: 0)
        ]

        let L2 = SKShapeNode(points: &p2, count: 2)
        let C2 = SKShapeNode(circleOfRadius: 10)
        L2.strokeColor = color; L2.fillColor = .clear
        C2.strokeColor = color; C2.fillColor = .clear

        ring2.addChild(L2)
        ring2.addChild(C2)

        ring1.addChild(ring2)
        ringShapes.append(ring2)
        return ring2
    }

    static func startRing1(settings: Settings, track0: SKShapeNode, ring1: SKShapeNode) {
        let track0Radius = track0.frame.width / 2
        let ring1Radius = ring1.frame.width / 2
        let ring0Radius = track0Radius + ring1Radius
        let sizeRatio = ring1Radius / ring0Radius

        let orbitDuration = 1 / settings.rotationRateHertz
        let orbit = SKAction.follow(track0.path!, asOffset: false, orientToPath: false, duration: orbitDuration)
        let orbitForever = SKAction.repeatForever(orbit)

        let spinDuration = sizeRatio * orbitDuration
        let spin = SKAction.rotate(byAngle: -.tau, duration: spinDuration)
        let spinForever = SKAction.repeatForever(spin)

        let group = SKAction.group([orbitForever, spinForever])
        ring1.run(group)
    }

    static func startRing2(settings: Settings, track1: SKShapeNode, ring2: SKShapeNode) {
        let track1Radius = track1.frame.width / 2
        let ring2Radius = ring2.frame.width / 2
        let ring1Radius = track1Radius + ring2Radius
        let sizeRatio = ring2Radius / ring1Radius

        let orbitDuration = 1 / settings.rotationRateHertz
        let orbit = SKAction.follow(track1.path!, asOffset: false, orientToPath: false, duration: orbitDuration)
        let orbitForever = SKAction.repeatForever(orbit.reversed())

        let spinDuration = sizeRatio * orbitDuration
        let spin = SKAction.rotate(byAngle: .tau, duration: spinDuration)
        let spinForever = SKAction.repeatForever(spin)

        let group = SKAction.group([orbitForever, spinForever])
        ring2.run(group)
    }

    static func drawPen(scene: ArenaScene, ring2: SKShapeNode) {
        let ring2Radius = ring2.frame.width / 2

        var penPoints: [CGPoint] = [
            .zero,
            CGPoint(x: +scene.settings.penLengthFraction * ring2Radius, y: 0)
        ]

        let penNode = SKShapeNode(points: &penPoints, count: 2)
        penNode.lineWidth = Settings.ringLineWidth
        penNode.fillColor = .green
        penNode.strokeColor = .red
        penNode.position = .zero

        penNode.alpha = scene.settings.showPen ? 1 : 0

        ring2.addChild(penNode)

        penShape = penNode
    }
}
