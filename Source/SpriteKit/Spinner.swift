// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit

class Spinner {
    let compensator: SKShapeNode
    let ringShape: SKShapeNode!
    let vectorShape: SKShapeNode!

    init(settings: Settings, scene: ArenaScene) {
        let rawSceneRadius = scene.frame.size.width / 2
        let ringRadius = rawSceneRadius * settings.ringRadiiFractions[0]

        ringShape = SKShapeNode(circleOfRadius: ringRadius)
        ringShape.fillColor = .clear
        ringShape.strokeColor = settings.ringColors[0]

        let sCompensator = CGSize(width: 10, height: 10)
        let oCompensator = CGPoint(x: -5, y: -5)
        let rCompensator = CGRect(origin: oCompensator, size: sCompensator)
        compensator = SKShapeNode(rect: rCompensator)

        let pCompensator = CGPoint.zero
        compensator.position = pCompensator

        compensator.fillColor = .orange
        compensator.strokeColor = .yellow

        scene.addChild(compensator)
        compensator.addChild(ringShape)

        vectorShape = nil
    }

    init(settings: Settings, parentSpinner: Spinner, layerIndex: Int) {
        let parentRingRadius = parentSpinner.ringShape.frame.size.width / 2

        let vectorLength = parentRingRadius * settings.ringRadiiFractions[layerIndex]
        let ringRadius = parentRingRadius * (1 - settings.ringRadiiFractions[layerIndex])

        ringShape = SKShapeNode(circleOfRadius: ringRadius)
        ringShape.fillColor = .clear
        ringShape.strokeColor = settings.ringColors[layerIndex]

        var pVector: [CGPoint] = [CGPoint(x: 0, y: 0), CGPoint(x: vectorLength, y: 0)]

        vectorShape = SKShapeNode(points: &pVector, count: 2)
        vectorShape.strokeColor = settings.ringColors[layerIndex]

        var pDebugMarker: [CGPoint] = [CGPoint(x: -vectorLength / 2, y: 0), CGPoint(x: vectorLength / 2, y: 0)]
        let debugMarker = SKShapeNode(points: &pDebugMarker, count: 2)
        debugMarker.strokeColor = settings.ringColors[layerIndex]
        debugMarker.zRotation += .tau / 4
        ringShape.addChild(debugMarker)

        let sCompensator = CGSize(width: 10, height: 10)
        let oCompensator = CGPoint(x: -5, y: -5)
        let rCompensator = CGRect(origin: oCompensator, size: sCompensator)

        compensator = SKShapeNode(rect: rCompensator)
        compensator.position = CGPoint(x: vectorLength, y: 0)
        compensator.fillColor = .clear

        parentSpinner.ringShape.addChild(vectorShape)
        vectorShape.addChild(compensator)
        compensator.addChild(ringShape)

        let direction = Double.tau * ((layerIndex % 2 == 0) ? -1.0 : 1.0)
        let cycleDuration = settings.ringRadiiFractions[layerIndex] / settings.rotationRateHertz

        let spinAction = SKAction.rotate(byAngle: direction, duration: cycleDuration)
        let spinForever = SKAction.repeatForever(spinAction)

        let compensateAction = SKAction.rotate(byAngle: -direction, duration: cycleDuration)
        let compensateForever = SKAction.repeatForever(compensateAction)

        compensator.run(compensateForever)
        debugMarker.run(compensateForever)
        vectorShape.run(spinForever)
    }
}
