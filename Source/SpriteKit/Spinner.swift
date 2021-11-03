// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit

class Spinner {
    let spacerShape: SKShapeNode!
    let compensator: SKShapeNode
    let penShape: SKShapeNode!
    let penTip: SKShapeNode!
    let ringShape: SKShapeNode!

    var inkHue = Double.random(in: 0..<1)

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

        compensator.position = .zero
        compensator.fillColor = .clear
        compensator.strokeColor = .clear

        scene.addChild(compensator)
        compensator.addChild(ringShape)

        spacerShape = nil
        penShape = nil
        penTip = nil
    }

    // swiftlint:disable function_body_length
    init(settings: Settings, parentSpinner: Spinner, layerIndex: Int) {
        let spacerFraction = Spinner.radiusFraction(settings: settings, layerIndex: layerIndex)
        let spacerLength = spacerFraction * parentSpinner.ringRadius()

        var pSpacer: [CGPoint] = [CGPoint(x: 0, y: 0), CGPoint(x: spacerLength, y: 0)]

        spacerShape = SKShapeNode(points: &pSpacer, count: 2)
        spacerShape.strokeColor = settings.ringColors[layerIndex]

        parentSpinner.ringShape.addChild(spacerShape)

        let sCompensator = CGSize(width: 10, height: 10)
        let oCompensator = CGPoint(x: -5, y: -5)
        let rCompensator = CGRect(origin: oCompensator, size: sCompensator)

        compensator = SKShapeNode(rect: rCompensator)
        compensator.position = CGPoint(x: spacerLength, y: 0)
        compensator.fillColor = .clear
        compensator.strokeColor = .clear

        spacerShape.addChild(compensator)

        let ringRadius = parentSpinner.ringRadius() - spacerLength
        ringShape = SKShapeNode(circleOfRadius: ringRadius)
        ringShape.fillColor = .clear
        ringShape.strokeColor = settings.ringColors[layerIndex]

        compensator.addChild(ringShape)

//        let penFraction = Spinner.radiusFraction(settings: settings, layerIndex: layerIndex)
        let penFraction = settings.penLengthFraction
        let penLength = ringRadius * penFraction

        var pPen: [CGPoint] = [CGPoint(x: 0, y: 0), CGPoint(x: penLength, y: 0)]
        penShape = SKShapeNode(points: &pPen, count: 2)
        penShape.strokeColor = settings.ringColors[layerIndex]
        penShape.zRotation += .tau / 4

        compensator.addChild(penShape)

        penTip = SKShapeNode(circleOfRadius: 2)
        penTip.position = CGPoint(x: penLength, y: 0)
        penTip.strokeColor = .clear

        penShape.addChild(penTip)

        let direction = Double.tau * ((layerIndex % 2 == 0) ? -1.0 : 1.0)
        let ringCycleDuration = 1 / settings.rotationRateHertz
        let penCycleDuration = ringCycleDuration * (ringRadius / parentSpinner.ringRadius())

        let penSpinAction = SKAction.rotate(byAngle: -direction, duration: penCycleDuration)
        let penSpinForever = SKAction.repeatForever(penSpinAction)

        let spinAction = SKAction.rotate(byAngle: direction, duration: ringCycleDuration)
        let spinForever = SKAction.repeatForever(spinAction)

        let compensateAction = SKAction.rotate(byAngle: -direction, duration: ringCycleDuration)
        let compensateForever = SKAction.repeatForever(compensateAction)

        compensator.run(compensateForever)
        penShape.run(penSpinForever)
        spacerShape.run(spinForever)
    }
}

private extension Spinner {
    static func radiusFraction(settings: Settings, layerIndex: Int) -> Double {
        settings.ringRadiiFractions[layerIndex]
    }

    func ringRadius() -> CGFloat { ringShape.frame.size.width / 2 }
}
