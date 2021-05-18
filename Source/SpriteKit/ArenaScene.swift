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

class ArenaScene: SKScene, SKSceneDelegate, SKPhysicsContactDelegate {
    let arkonsPool: SpritePool
    let filledRectanglesPool: SpritePool
    let linesPool: SpritePool
    let nosesPool: SpritePool
    let rectanglesPool: SpritePool
    let ringsPool: SpritePool
    let teethPool: SpritePool

    let sceneDispatch = SceneDispatch()

    private var tickCount = 0

    var readyToRun = false

    override init(size: CGSize) {
        self.arkonsPool = SpritePool("Arkons", "spark-thorax-large")
        self.filledRectanglesPool = SpritePool("Markers", "rectangle-solid")
        self.linesPool = SpritePool("Markers", "line")
        self.nosesPool = SpritePool("Arkons", "diploid-nose")
        self.rectanglesPool = SpritePool("Markers", "rectangle")
        self.ringsPool = SpritePool("Markers", "circle-solid")
        self.teethPool = SpritePool("Arkons", "spark-tooth-large")

        super.init(size: size)

        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var boxes = [SKSpriteNode]()

    func makeBox(color: SKColor) {
        let box = arenaScene.arkonsPool.makeSprite()

        box.size = CGSize(width: 25, height: 25)
        box.color = color
        box.colorBlendFactor = 1

        let p1 = SKPhysicsBody(circleOfRadius: box.size.width / 2)

        p1.isDynamic = true

        p1.categoryBitMask = 1
        p1.collisionBitMask = 3
        p1.contactTestBitMask = 1

        self.addChild(box)

        let hw = size.width / 2
        let hh = size.height / 2
        box.position = CGPoint(x: CGFloat.random(in: -hw...hw), y: CGFloat.random(in: -hh...hh))
        box.physicsBody = p1

        self.boxes.append(box)
    }

    override func didMove(to view: SKView) {
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsPhysics = true

        let halfSceneWidth = size.width / 2
        let halfSceneHeight = size.height / 2

        guard let scene = self.scene else {
            preconditionFailure("This should never happen")
        }

        scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        scene.physicsWorld.contactDelegate = self

        let boundary = SKPhysicsBody(edgeLoopFrom: CGRect(
            x: -halfSceneWidth + 4, y: -halfSceneHeight + 2,
            width: 0.75 * Config.sceneWidthPix,
            height: 0.75 * Config.sceneWidthPix * Config.xScaleToSquare
        ))

        boundary.isDynamic = false
        boundary.contactTestBitMask = 0
        boundary.categoryBitMask = 2
        boundary.collisionBitMask = 3

        let boundaryNode = SKNode()
        boundaryNode.physicsBody = boundary
        self.addChild(boundaryNode)

//        let dragNode = SKFieldNode.dragField()
//        dragNode.strength = 1
//        self.addChild(dragNode)

        makeBox(color: .green)
//        makeBox(color: .orange)
        startPulse()

        backgroundColor = .black
        readyToRun = true
    }

    func startPulse() {
        for box in boxes.indices {
            pulse(box)
        }
    }

    func pulse(_ box: Int) {
        let radius = CGFloat(3)// CGFloat.random(in: 5..<10)
        let theta = CGFloat.random(in: 0..<(2 * .pi))

        let sequence: SKAction
        if box % 2 == 0 {
            let p1 = SKAction.applyImpulse(CGVector(radius: radius, theta: theta), duration: 0.1)
            let p3 = SKAction.applyForce(CGVector(radius: -0.75 * radius, theta: theta), duration: 1.25)
            let p4 = SKAction.wait(forDuration: 1)

            sequence = SKAction.sequence([p1, p3, p4])
        } else {
            let p1 = SKAction.applyImpulse(CGVector(radius: radius, theta: theta), duration: 0.5)
            let p2 = SKAction.applyImpulse(CGVector(radius: -radius, theta: theta), duration: 0.1)
            let p3 = SKAction.wait(forDuration: 1)

            sequence = SKAction.sequence([p1, p2, p3])
        }

        boxes[box].run(sequence) { self.pulse(box) }
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
