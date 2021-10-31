// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit
import SwiftUI
import Combine

enum DisplayCycle: Int {
    case updateStarted, didFinishUpdate
    case evaluatingActions, didEvaluateActions
    case simulatingPhysics, didSimulatePhysics
    case applyingConstraints, didApplyConstraints
    case renderingScene
    case idle

    func isIn(_ state: DisplayCycle) -> Bool {
        return self.rawValue == state.rawValue
    }

    func isPast(_ milestone: DisplayCycle) -> Bool {
        return self.rawValue >= milestone.rawValue
    }
}

struct Display {
    static var displayCycle: DisplayCycle = .idle
}

enum ActionStatus {
    case none, running, finished
}

class ArenaScene: SKScene, SKSceneDelegate, SKPhysicsContactDelegate, ObservableObject {
    var settings: Settings

    let dotsPool: SpritePool

    let sceneDispatch = SceneDispatch()

    private var tickCount = 0

    var readyToRun = false
    var actionStatus = ActionStatus.none

    var theta0 = 0.0

//    var rings = [SKShapeNode]()
    var topRingIx: Int { ringShapes.count - 1 }

    private var cancellables = Set<AnyCancellable>()

    init(settings: Settings, size: CGSize) {
        self.settings = settings
        self.dotsPool = SpritePool("Markers", "circle-solid", cPreallocate: 10000)
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
//        settings.$rotationRateHertz.sink(receiveCompletion: { _ in
//        }, receiveValue: { value in
//            DispatchQueue.global(qos: .userInitiated).async {
//                settings.rotationRateHertz = value
//            }
//        }).store(in: &cancellables)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var ringShapes = [SKShapeNode]()

    override func didMove(to view: SKView) {
        self.speed = settings.simulationSpeed

        view.showsFPS = true
        view.showsNodeCount = true

        backgroundColor = .black

        DrawRing.drawRing0(scene: self)

        _ = DrawRing.drawTrack0(scene: self, ring0: DrawRing.ringShapes[0])
        _ = DrawRing.drawRing1(scene: self, ring0: DrawRing.ringShapes[0])

//        DrawRing.startRing1(settings: settings, track0: track0, ring1: ring1)

        let track1 = DrawRing.drawTrack1(scene: self, ring1: DrawRing.ringShapes[1])
        let ring2 = DrawRing.drawRing2(scene: self, ring1: DrawRing.ringShapes[1])

        DrawRing.startRing2(settings: settings, track1: track1, ring2: ring2)

//        let r2 = SKShapeNode(circleOfRadius: radiusOf(ring: r1) * rScaleFactors[2])
//        ringShapes.append(r2)
//
//        let t1Radius = radiusOf(ring: r0) - radiusOf(ring: r1)
//        let t2Radius = radiusOf(ring: r1) - radiusOf(ring: r2)
//
//        let t1 = SKShapeNode(circleOfRadius: t1Radius)
//        let t2 = SKShapeNode(circleOfRadius: t2Radius)
//
//        var penLinePath: [CGPoint] = [
//            .zero,
//            CGPoint(x: settings.penLengthFraction * radiusOf(ring: t2), y: 0)
//        ]
//
//        let pen = SKShapeNode(points: &penLinePath, count: 2)
//
//        self.addChild(r0)
//        r0.addChild(t1)
//        r1.addChild(t2)
//
//        r0.addChild(r1)
//        t2.addChild(r2)
//
//        r2.addChild(pen)

//        r0.fillColor = .clear; r0.strokeColor = .cyan
//        r1.fillColor = .clear; r1.strokeColor = .magenta
//        r2.fillColor = .clear; r2.strokeColor = .orange

//        t1.fillColor = .clear; t1.strokeColor = .blue; t1.zPosition = 5
//        t1.position = .zero
//
//        t2.fillColor = .clear; t2.strokeColor = .white; t2.zPosition = 5
//        t2.position = CGPoint(x: radiusOf(ring: r1) - radiusOf(ring: r2), y: 0)
//
//        r0.lineWidth = 0.1
//        r0.setScale(1)

//        let orbitDuration = 1 / settings.rotationRateHertz
//        let orbit = SKAction.follow(trackPath(ring: 0), asOffset: false, orientToPath: false, duration: orbitDuration)
//        let orbitForever = SKAction.repeatForever(orbit)
//
//        let spin = SKAction.rotate(byAngle: -.tau, duration: orbitDuration)
//        let spinForever = SKAction.repeatForever(spin)
//
//        let group = SKAction.group([orbitForever, spinForever])
//        r1.run(group)

//        rings.append(Ring(scene: self))
//        self.addChild(rings[0].shapeNode)
//
//        rings.append(Ring(scene: self, ringIndex: 1))
//        rings.append(Ring(scene: self, ringIndex: 2))
//
//        rings[0].shapeNode.addChild(rings[1].shapeNode)
//        rings[1].shapeNode.addChild(rings[2].shapeNode)
//
//        let fullExtension = trackPathRadius(ring: topRingIx) + penLength() / 2
//        if fullExtension / shapeNodeRadius(ring: 0) > 1.0 {
//            rings[0].shapeNode.setScale(0.95 * trackPathRadius(ring: topRingIx) / fullExtension)
//        }
//
//        readyToRun = true
//
//        let spin1 = SKAction.rotate(byAngle: -.tau, duration: spinDuration(ring: 1))
//        let spinF1rever = SKAction.repeatForever(spin1)
//
//        let roll1 = SKAction.follow(trackPath(ring: 1), asOffset: false, orientToPath: false, duration: 1 / settings.rotationRateHertz)
//        let rollF1rever = SKAction.repeatForever(roll1)
//
//        let group = SKAction.group([spinF1rever, rollF1rever])
//
//        let setStatus = SKAction.run { self.actionStatus = .running }
//        let sequence = SKAction.sequence([setStatus, group])
//        rings[1].shapeNode.run(sequence)
    }

    override func update(_ currentTime: TimeInterval) {
        defer { Display.displayCycle = .evaluatingActions }
        Display.displayCycle = .updateStarted

        guard readyToRun else { return }

        // We used to be able to set these flags in didMove(to: View), but
        // after I upgraded to Monterey, they didn't show up in the view any
        // more. Might not be because of Monterey, but atm I don't give a shit,
        // I just wanted to verify that everything isn't broken all to hell.
        if view!.showsFPS == false {
            view!.showsFPS = true
            view!.showsNodeCount = true
        }

        sceneDispatch.tick(tickCount)

        tickCount += 1
    }
}

extension ArenaScene {
    override func didEvaluateActions() {
        defer { Display.displayCycle = .simulatingPhysics }
        Display.displayCycle = .didEvaluateActions

        if actionStatus == .none { return }

//        let hue = Double(tickCount % 600) / 600
//        let color = NSColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
//
//        theta0 = (theta0 + .tau * settings.rotationRateHertz / 60).truncatingRemainder(dividingBy: .tau)
//
//        let easyDot = dotsPool.makeSprite()
//        easyDot.size = CGSize(width: 5, height: 5)
//        easyDot.color = color
//        easyDot.alpha = 0.85
//
//        easyDot.position = penAbsolutePosition()
//        rings[0].shapeNode.addChild(easyDot)
//
//        let fade = SKAction.fadeOut(withDuration: Settings.pathFadeDurationSeconds)
//        easyDot.run(fade) {
//            self.dotsPool.releaseSprite(easyDot)
//        }

        if actionStatus == .finished { actionStatus = .none }
    }

    override func didFinishUpdate() {
        defer { Display.displayCycle = .renderingScene }
        Display.displayCycle = .didFinishUpdate
    }

    override func didSimulatePhysics() {
        defer { Display.displayCycle = .applyingConstraints }
        Display.displayCycle = .didSimulatePhysics
    }
}

extension ArenaScene {
//    func penLength() -> CGFloat {
//        return rings[topRingIx].penNode!.frame.size.width
//    }
//
//    func penAbsolutePosition() -> CGPoint {
//        let p = CGPoint(x: penLength(), y: 0)
//        return rings[topRingIx].penNode!.convert(p, to: rings[0].shapeNode)
//    }
//
    func radiusOf(ring: SKShapeNode) -> CGFloat {
        ring.frame.size.width / 2.0
    }

    func radiusOf(ring: SKSpriteNode) -> CGFloat {
        ring.frame.size.width / 2.0
    }

    func shapeNodeRadius(ring: Int) -> CGFloat {
        ringShapes[ring].frame.size.width / 2
    }
//
//    func spinDuration(ring: Int) -> TimeInterval {
//        rings[ring].radiusFraction / settings.rotationRateHertz
//    }
//
    func trackPath(ring: Int) -> CGPath {
        ringShapes[ring].path!
//        rings[ring].trackPath!
    }
//
//    func trackPathRadius(ring: Int) -> CGFloat {
//        rings[ring].trackPath!.boundingBox.size.width / 2
//    }
}
