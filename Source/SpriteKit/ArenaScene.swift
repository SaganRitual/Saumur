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

    var pen: SKSpriteNode!
    var dot: SKSpriteNode!
    var path1: CGPath!
    var ring0: SKSpriteNode!
    var ring1: SKSpriteNode!
    var ring0Radius = 0.0
    var ring1Radius = 0.0

    var theta0 = 0.0
    var rotationRateHertz = 0.0
    private var cancellables = Set<AnyCancellable>()
    init(settings: Settings, size: CGSize) {
        self.settings = settings
        self.dotsPool = SpritePool("Markers", "circle-solid", cPreallocate: 10000)
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        settings.$rotationRateHertz.sink(receiveCompletion: { _ in
        }, receiveValue: { value in
            DispatchQueue.global(qos: .userInitiated).async {
                self.rotationRateHertz = value
            }
        }).store(in: &cancellables)

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

        let follow = SKAction.follow(path1, asOffset: false, orientToPath: false, duration: 1 / rotationRateHertz)
        let followForever = SKAction.repeatForever(follow)
        let ratio = ring0Radius / ring1Radius
        let spin = SKAction.rotate(byAngle: -.tau, duration: 1 / (ratio * rotationRateHertz))
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

        makeRing0()
        makeRing1()

        track1Radius = ring0Radius - ring1Radius
        readyToRun = true
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

        theta0 = (theta0 + .tau * rotationRateHertz / 60).truncatingRemainder(dividingBy: .tau)

        let easyDot = dotsPool.makeSprite()
        easyDot.size = CGSize(width: 5, height: 5)
        easyDot.color = .clear
        easyDot.alpha = 0.85

        let hardDot = dotsPool.makeSprite()
        hardDot.size = CGSize(width: 10, height: 10)
        hardDot.color = color

//        let wtf1Radius = abs(radiusOf(ring: ring0) - radiusOf(ring: ring1))
//        print("wtf1Radius = \(wtf1Radius) = \(radiusOf(ring: ring0)) - \(radiusOf(ring: ring1))")

        let penx = pen.frame.width
        let peny = 0.0
        let penp = CGPoint(x: penx, y: peny)

        easyDot.position = pen.convert(penp, to: ring0)

        let theta1 = (.pi - theta0 * ring1Radius / ring0Radius * rotationRateHertz).truncatingRemainder(dividingBy: .tau)
        let xPen = ring1Radius * cos(theta1)
        let yPen = ring1Radius * sin(theta1)
        let pPen = CGPoint(x: xPen, y: yPen)

        hardDot.position = ring1.convert(pPen, to: ring0)
//
//        let penToRing1 = pen.convert(pPen, to: ring1)
//        let ring1ToArena = ring1.convert(pRing1 + penToRing1, to: self)
//        newPathDot.position = ring1ToArena

//        print("t = \(theta0), pRing0 = \(pRing0), r0 \(radiusOf(ring: ring0)) r1 \(radiusOf(ring: ring1)), track1 \(pRing0.x / cos(theta0)) \(pRing0.y / sin(theta0))")

        ring0.addChild(easyDot)
        ring0.addChild(hardDot)

        let fade = SKAction.fadeOut(withDuration: Settings.pathFadeDurationSeconds)
        hardDot.run(fade) {
            self.dotsPool.releaseSprite(hardDot)
        }

//        actionStatus = .finished

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
