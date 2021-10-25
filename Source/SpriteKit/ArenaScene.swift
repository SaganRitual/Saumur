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

class ArenaScene: SKScene, SKSceneDelegate, SKPhysicsContactDelegate {
    let dotsPool: SpritePool
    let linesPool: SpritePool
    let ringsPool: SpritePool

    let sceneDispatch = SceneDispatch()

    private var tickCount = 0

    var readyToRun = false
    var actionStatus = ActionStatus.none

    override init(size: CGSize) {
        self.dotsPool = SpritePool("Markers", "circle-solid")
        self.linesPool = SpritePool("Markers", "rectangle")
        self.ringsPool = SpritePool("Markers", "circle")

        super.init(size: size)

        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var rings = [SKShapeNode]()
    var drawingDots = [SKShapeNode]()

    func makeRing(_ color: SKColor = .clear) {
        let ring = SKShapeNode(circleOfRadius: 50)
        ring.lineWidth = 5
        ring.fillColor = .clear
        ring.strokeColor = .white

        let yRing = (ring.frame.size.height / 2) + (ring.lineWidth / 4)
        let xRing = ((-size.width + ring.frame.size.width) / 2)

        ring.position = CGPoint(x: xRing, y: yRing)

        let dot = SKShapeNode(circleOfRadius: 5)
        dot.lineWidth = 0
        dot.fillColor = .red
        dot.strokeColor = .clear

        let xDot = ((ring.frame.size.width - dot.frame.size.width) / 2) +
                    (ring.lineWidth / 4)

        dot.position = CGPoint(x: xDot, y: 0)

        self.addChild(ring)
        ring.addChild(dot)

        rings.append(ring)
        drawingDots.append(dot)
    }

    override func didMove(to view: SKView) {
        view.showsFPS = true
        view.showsNodeCount = true

        makeRing()
        pulse(0)

        backgroundColor = .black
        readyToRun = true
    }

    func startPulse() {
        for box in rings.indices {
            pulse(box)
        }
    }

    func pulse(_ box: Int) {
        let duration = CGFloat(10)
        let rotate = SKAction.rotate(byAngle: -CGFloat.tau, duration: duration)

        let distance = CGFloat.pi * 100
        let vector = CGVector(dx: distance, dy: 0)
        let traverse = SKAction.move(by: vector, duration: duration)

        let startSprites = SKAction.run  { self.actionStatus = .running }
        let groupAction = SKAction.group([rotate, traverse])
        let wait = SKAction.wait(forDuration: 2.0)
        let sequenceAction = SKAction.sequence([wait, startSprites, groupAction])

        rings[box].run(sequenceAction) { self.actionStatus = .finished }
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

        let hue = Double(tickCount % 120) / 120
        let color = NSColor(hue: hue, saturation: 0.5, brightness: 0.9, alpha: 1)

        if tickCount % 2 == 0 {
            let newPathDot = SKShapeNode(circleOfRadius: 5)
            newPathDot.lineWidth = 1
            newPathDot.fillColor = color
            newPathDot.strokeColor = color

            let arenaPosition = rings[0].convert(drawingDots[0].position, to: self)
            newPathDot.position = arenaPosition

            addChild(newPathDot)
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
