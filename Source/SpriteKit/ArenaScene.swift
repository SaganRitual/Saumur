// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit

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

enum Settings {
    static let pathFadeDurationSeconds: CGFloat = 20

    static let ring0LineWidth: CGFloat = 3
    static let ring0Radius: CGFloat = 100

    static let ring1DrawpointFraction: CGFloat = 1.7
    static let ring1LineWidth: CGFloat = 3
    static let ring1RadiusFraction: CGFloat = 0.5

    static let ring1Radius: CGFloat = ring1RadiusFraction * ring0Radius

    static let speedHertz: CGFloat = 1
}

class ArenaScene: SKScene, SKSceneDelegate, SKPhysicsContactDelegate {
    let dotsPool: SpritePool

    let sceneDispatch = SceneDispatch()

    private var tickCount = 0

    var readyToRun = false
    var actionStatus = ActionStatus.none

    var bar: SKShapeNode!
    var dot: SKShapeNode!
    var ring1: SKShapeNode!
    var ring0: SKShapeNode!

    override init(size: CGSize) {
        self.dotsPool = SpritePool("Markers", "circle-solid", cPreallocate: 10000)

        super.init(size: size)

        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeRing0() {
        ring0 = SKShapeNode(circleOfRadius: Settings.ring0Radius)

        ring0.lineWidth = Settings.ring0LineWidth
        ring0.fillColor = .clear
        ring0.strokeColor = .white
        ring0.position = CGPoint.zero

        self.addChild(ring0)
    }

    var path: CGPath!
    var table1: SKShapeNode!

    func makeInnerRing() {
        ring1 = SKShapeNode(circleOfRadius: Settings.ring1Radius)
        ring1.lineWidth = Settings.ring1LineWidth
        ring1.fillColor = .clear
        ring1.strokeColor = .white

        let xxRing = (ring0.frame.size.width - ring1.frame.size.width) / 2
        ring1.position = CGPoint(x: xxRing, y: 0)

        let wBar = ring1.frame.size.width - Settings.ring1LineWidth

        bar = SKShapeNode(rectOf: CGSize(width: wBar, height: 1))
        bar.lineWidth = 0
        bar.fillColor = .white
        bar.strokeColor = .clear

        dot = SKShapeNode(circleOfRadius: 1)
        dot.lineWidth = 0
        dot.fillColor = .red
        dot.strokeColor = .clear
        dot.zPosition = 2

        let dp = Settings.ring1DrawpointFraction * ring1.frame.size.width / 2
        dot.position = CGPoint(x: dp, y: 0)

        ring1.addChild(bar)
        bar.addChild(dot)

        let track1Radius = (ring0.frame.size.width - ring1.frame.size.width) / 2
        let track1Diameter = track1Radius * 2
        let track1Size = CGSize(width: track1Diameter, height: track1Diameter)

        let xRing = -(ring0.frame.size.width - ring1.frame.size.width) / 2
        let yRing = -(ring0.frame.size.height - ring1.frame.size.height) / 2
        let track1Origin = CGPoint(x: xRing, y: yRing)

        path = CGPath(ellipseIn: CGRect(origin: track1Origin, size: track1Size), transform: nil)
        table1 = SKShapeNode(path: path)
        table1.fillColor = .clear
        table1.strokeColor = .clear
        self.addChild(table1)
        table1.addChild(ring1)
    }

    override func didMove(to view: SKView) {
        view.showsFPS = true
        view.showsNodeCount = true

        makeRing0()
        makeInnerRing()

        backgroundColor = .black
        readyToRun = true

        pulse()
    }

    func pulse() {

        let duration = CGFloat(1 / Settings.speedHertz)
        let rotateTable1 = SKAction.rotate(byAngle: CGFloat.tau, duration: duration)
        let rotateForeverTable1 = SKAction.repeatForever(rotateTable1)

        let circumferenceRing0 = CGFloat.pi * ring0.frame.width
        let circumferenceRing1 = CGFloat.pi * ring1.frame.width
        let ring1Rotations = circumferenceRing0 / circumferenceRing1

        let rotateRing1 = SKAction.rotate(byAngle: -CGFloat.tau * ring1Rotations, duration: duration)
        let rotateForeverRing1 = SKAction.repeatForever(rotateRing1)

        let startSprites = SKAction.run { self.actionStatus = .running }
        let wait = SKAction.wait(forDuration: 2)
        let rotateForever = SKAction.run { [self] in
            table1.run(rotateForeverTable1)
            ring1.run(rotateForeverRing1)
        }

        let sequenceAction = SKAction.sequence([wait, startSprites, rotateForever])
        self.run(sequenceAction)
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
