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
    var topRingIx: Int { ringShapes.count - 1 }

    private var cancellables = Set<AnyCancellable>()

    init(settings: Settings, size: CGSize) {
        self.settings = settings
        self.dotsPool = SpritePool("Markers", "circle-solid", cPreallocate: 10000)

        super.init(size: size)

        anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    // Schwamova 1:30 B♭+D, 5:14-5:26, 5:34, Similar but not quite at 7:25, 7:36, even closer at 7:40
    // 1:40 D+A♭, 4:08, 5:12, 7:12-7:21, 7:52-8:00 k448
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var ringShapes = [SKShapeNode]()

    var spinners = [Spinner]()

    override func didMove(to view: SKView) {
        self.speed = settings.simulationSpeed

        view.showsFPS = true
        view.showsNodeCount = true

        backgroundColor = NSColor.windowBackgroundColor

        let base = Spinner(settings: settings, scene: self)
        let spinner1 = Spinner(settings: settings, parentSpinner: base, layerIndex: 1)
        let spinner2 = Spinner(settings: settings, parentSpinner: spinner1, layerIndex: 2)
        let spinner3 = Spinner(settings: settings, parentSpinner: spinner2, layerIndex: 3)

        spinners.append(base)
        spinners.append(spinner1)
        spinners.append(spinner2)
        spinners.append(spinner3)

        readyToRun = true

        let startActions = SKAction.run { self.actionStatus = .running }
        self.run(startActions)
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

        for ix in 1..<spinners.count {
            let adjustedHue = (spinners[ix].inkHue + hue).truncatingRemainder(dividingBy: 1)
            let color = NSColor(hue: adjustedHue, saturation: 1, brightness: 1, alpha: 1)

            let easyDot = dotsPool.makeSprite()
            easyDot.size = CGSize(width: 5, height: 5)
            easyDot.color = color
            easyDot.alpha = 0.85

            let penTip = spinners[ix].penTip!
            let dotPosition = spinners[ix].penShape.convert(penTip.position, to: self)

            easyDot.position = dotPosition
            self.addChild(easyDot)

            let pathFadeDurationSeconds = Settings.pathFadeDurationSeconds * self.speed
            let fade = SKAction.fadeOut(withDuration: pathFadeDurationSeconds)
            easyDot.run(fade) {
                self.dotsPool.releaseSprite(easyDot)
            }
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

extension ArenaScene {
//    func penLength() -> CGFloat {
//        return DrawRing.penShape!.frame.size.width
//    }
//
//    func penAbsolutePosition() -> CGPoint {
//        let p = CGPoint(x: penLength(), y: 0)
//        return DrawRing.penShape!.convert(p, to: DrawRing.ringShapes[0])
//    }

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
