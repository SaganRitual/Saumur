// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit
import SwiftUI

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

class ArenaScene: SKScene, SKSceneDelegate, SKPhysicsContactDelegate {
    @ObservedObject var settings: Settings

    let dotsPool: SpritePool

    let sceneDispatch = SceneDispatch()

    private var tickCount = 0

    var readyToRun = false
    var actionStatus = ActionStatus.none

    var pen: SKSpriteNode!
    var dot: SKSpriteNode!
    var path1: CGPath!
    var ring0: SKSpriteNode!
    var ring1: SKSpriteNode!

    var ring0Radius = 0.0
    var ring1Radius = 0.0

    var theta0 = 0.0

    var nRing0: Ring?
    var nRing1: Ring?

    init(settings: Settings, size: CGSize) {
        self.dotsPool = SpritePool("Markers", "circle-solid", cPreallocate: 10000)
        self.settings = settings

        super.init(size: size)

        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeRing0() {
        let r0 = SKShapeNode(circleOfRadius: 0.95 * self.frame.width / 2)

        r0.lineWidth = Settings.ringLineWidth
        r0.fillColor = .clear
        r0.strokeColor = .white
        r0.position = CGPoint.zero

        let t0 = self.view!.texture(from: r0)
        ring0 = SKSpriteNode(texture: t0)
        ring0.zPosition = 2
        ring0.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        ring0Radius = radiusOf(ring: ring0)

        self.addChild(ring0)
    }

    func makeRing1() {
        let r1 = SKShapeNode(circleOfRadius: 0.25 * ring0Radius)
        r1.lineWidth = Settings.ringLineWidth
        r1.fillColor = .clear
        r1.strokeColor = .white

        let t1 = self.view!.texture(from: r1)
        ring1 = SKSpriteNode(texture: t1)
        ring1.zPosition = 2
        ring1.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        ring1Radius = radiusOf(ring: ring1)

        let xRing1 = ring0Radius - ring1Radius
        let yRing1 = 0.0

        ring1.position = CGPoint(x: xRing1, y: yRing1)
        self.addChild(ring1)

        let path1Origin = CGPoint(x: -ring1.position.x, y: -ring1.position.x)
        let path1Frame = CGRect(origin: path1Origin, size: CGSize(width: xRing1 * 2, height: xRing1 * 2))

        path1 = CGPath(ellipseIn: path1Frame, transform: nil)

        let follow = SKAction.follow(path1, asOffset: false, orientToPath: false, duration: 1 / settings.rotationRateHertz)
        let followForever = SKAction.repeatForever(follow)
        let ratio = ring0Radius / ring1Radius
        let spin = SKAction.rotate(byAngle: -.tau, duration: 1 / (ratio * settings.rotationRateHertz))
        let spinForever = SKAction.repeatForever(spin)
        let setStatus = SKAction.run { self.actionStatus = .running }
        let group = SKAction.group([followForever, spinForever])
        let sequence = SKAction.sequence([setStatus, group])
        ring1.run(sequence)

        let p0 = SKShapeNode(rect: CGRect(origin: .zero, size: CGSize(width: ring1Radius, height: 1)))
        p0.strokeColor = .red
        p0.fillColor = .clear
        p0.position = .zero

        let t0 = self.view!.texture(from: p0)
        pen = SKSpriteNode(texture: t0)
        pen.zPosition = 2
        pen.anchorPoint = CGPoint(x: 1.0, y: 0.5)

        ring1.addChild(pen)

//        let d0 = SKShapeNode(circleOfRadius: 1)
//        d0.lineWidth = 0
//        d0.fillColor = .red
//        d0.strokeColor = .clear
//        d0.zPosition = 2
//        d0.position.x = radiusOf(ring: ring1)
//
//        let d00d00 = self.view!.texture(from: d0)
//        dot = SKSpriteNode(texture: d00d00)
//        dot.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//
//        pen.addChild(dot)
//
//        let debug1 = SKShapeNode(path: path1)
//        debug1.lineWidth = Settings.ringLineWidth
//        debug1.fillColor = .clear
//        debug1.strokeColor = .green
//        debug1.position = .zero
//        self.addChild(debug1)
    }

    var track1Radius = 0.0

    override func didMove(to view: SKView) {
        view.showsFPS = true
        view.showsNodeCount = true

        backgroundColor = .black

        nRing0 = Ring(scene: self)
        self.addChild(nRing0!.shapeNode)

        nRing1 = Ring(
            scene: self,
            parentRadius: nRing0!.shapeNode.frame.size.width / 2,
            radiusFraction: settings.ring1RadiusFraction,
            isTopRing: true
        )

        nRing0!.shapeNode.addChild(nRing1!.shapeNode)

        let fullExtension = (nRing1!.trackPath!.boundingBox.size.width + nRing1!.penNode!.frame.width) / 2
        if fullExtension / (nRing0!.shapeNode.frame.size.width / 2) > 1.0 {
            nRing0!.shapeNode.setScale(0.95 * (nRing1!.trackPath!.boundingBox.size.width / fullExtension) / 2)
        }

        readyToRun = true

        let spin1 = SKAction.rotate(byAngle: -.tau, duration: nRing1!.radiusFraction / settings.rotationRateHertz)
        let spinF1rever = SKAction.repeatForever(spin1)

        let roll1 = SKAction.follow(nRing1!.trackPath!, asOffset: false, orientToPath: false, duration: 1 / settings.rotationRateHertz)
        let rollF1rever = SKAction.repeatForever(roll1)

        let group = SKAction.group([spinF1rever, rollF1rever])

        let setStatus = SKAction.run { self.actionStatus = .running }
        let sequence = SKAction.sequence([setStatus, group])
        nRing1!.shapeNode.run(sequence)
    }

    func radiusOf(ring: SKShapeNode) -> CGFloat {
        ring.frame.size.width / 2
    }

    func radiusOf(ring: SKSpriteNode) -> CGFloat {
        ring.frame.size.width / 2
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

        let hue = Double(tickCount % 600) / 600
        let color = NSColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)

        let easyDot = dotsPool.makeSprite()
        easyDot.size = CGSize(width: 5, height: 5)
        easyDot.color = color
        easyDot.alpha = 0.85

        let p = CGPoint(x: nRing1!.penNode!.frame.size.width, y: 0)
        easyDot.position = nRing1!.penNode!.convert(p, to: nRing0!.shapeNode)
        nRing0!.shapeNode.addChild(easyDot)

        let fade = SKAction.fadeOut(withDuration: Settings.pathFadeDurationSeconds)
        easyDot.run(fade) {
            self.dotsPool.releaseSprite(easyDot)
        }

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
