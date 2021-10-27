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

    var pen: SKShapeNode!
    var dot: SKShapeNode!
    var ring1: SKShapeNode!
    var ring0: SKShapeNode!

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
        ring0 = SKShapeNode(circleOfRadius: 0.95 * self.frame.width / 2)

        ring0.lineWidth = Settings.ringLineWidth
        ring0.fillColor = .clear
        ring0.strokeColor = .white
        ring0.position = CGPoint.zero

        self.addChild(ring0)
    }

    func makeRing1() {
        ring1 = SKShapeNode(circleOfRadius: ring0.frame.width / 2)
        ring1.lineWidth = Settings.ringLineWidth
        ring1.fillColor = .clear
        ring1.strokeColor = .white

    }

    func makeInnerRing() {
//        ring1 = SKShapeNode(circleOfRadius: ring0.frame.width / 2)
//        ring1.lineWidth = Settings.ringLineWidth
//        ring1.fillColor = .clear
//        ring1.strokeColor = .white
//
//        let xxRing = (ring0.frame.size.width - ring1.frame.size.width) / 2
//        ring1.position = CGPoint(x: xxRing, y: 0)
//
//        let wPen = ring1.frame.size.width - Settings.ringLineWidth
//
//        pen = SKShapeNode(rectOf: CGSize(width: wPen, height: 1))
//        pen.lineWidth = 0
//        pen.fillColor = .white
//        pen.strokeColor = .clear
//
//        dot = SKShapeNode(circleOfRadius: 1)
//        dot.lineWidth = 0
//        dot.fillColor = .red
//        dot.strokeColor = .clear
//        dot.zPosition = 2
//
//        let dp = Settings.ring1DrawpointFraction * ring1.frame.size.width / 2
//        dot.position = CGPoint(x: dp, y: 0)
//
//        ring1.addChild(pen)
//        pen.addChild(dot)
//
//        let track1Radius = (ring0.frame.size.width - ring1.frame.size.width) / 2
//        let track1Diameter = track1Radius * 2
//        let track1Size = CGSize(width: track1Diameter, height: track1Diameter)
//
//        let xRing = -(ring0.frame.size.width - ring1.frame.size.width) / 2
//        let yRing = -(ring0.frame.size.height - ring1.frame.size.height) / 2
//        let track1Origin = CGPoint(x: xRing, y: yRing)
//
//        path = CGPath(ellipseIn: CGRect(origin: track1Origin, size: track1Size), transform: nil)
//        table1 = SKShapeNode(path: path)
//        table1.fillColor = .clear
//        table1.strokeColor = .clear
//        self.addChild(table1)
//        table1.addChild(ring1)
    }

    override func didMove(to view: SKView) {
        view.showsFPS = true
        view.showsNodeCount = true

        backgroundColor = .black

        makeRing0()
        makeRing1()

        readyToRun = true
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

        let newPathDot = dotsPool.makeSprite()
        newPathDot.size = CGSize(width: 10, height: 10)
        newPathDot.color = color

        let arenaPosition = ring1.convert(dot.position, to: self)
        newPathDot.position = arenaPosition

        addChild(newPathDot)

        let fade = SKAction.fadeOut(withDuration: Settings.pathFadeDurationSeconds)
        newPathDot.run(fade) {
            self.dotsPool.releaseSprite(newPathDot)
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
