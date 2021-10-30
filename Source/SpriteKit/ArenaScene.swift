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

    var rings = [Ring]()
    var topRingIx: Int?

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

    override func didMove(to view: SKView) {
        view.showsFPS = true
        view.showsNodeCount = true

        backgroundColor = .black

        rings.append(Ring(scene: self))
        self.addChild(rings[0].shapeNode)

        rings.append(Ring(
            scene: self,
            parentRadius: shapeNodeRadius(ring: 0),
            radiusFraction: settings.ringRadiiFractions[1],
            isTopRing: true
        ))

        topRingIx = 1

        rings[0].shapeNode.addChild(rings[1].shapeNode)

        let fullExtension = trackPathRadius(ring: 1) + penLength() / 2
        if fullExtension / shapeNodeRadius(ring: 0) > 1.0 {
            rings[0].shapeNode.setScale(0.95 * trackPathRadius(ring: 1) / fullExtension)
        }

        readyToRun = true

        let spin1 = SKAction.rotate(byAngle: -.tau, duration: spinDuration(ring: 1))
        let spinF1rever = SKAction.repeatForever(spin1)

        let roll1 = SKAction.follow(trackPath(ring: 1), asOffset: false, orientToPath: false, duration: 1 / settings.rotationRateHertz)
        let rollF1rever = SKAction.repeatForever(roll1)

        let group = SKAction.group([spinF1rever, rollF1rever])

        let setStatus = SKAction.run { self.actionStatus = .running }
        let sequence = SKAction.sequence([setStatus, group])
        rings[1].shapeNode.run(sequence)
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

        theta0 = (theta0 + .tau * settings.rotationRateHertz / 60).truncatingRemainder(dividingBy: .tau)

        let easyDot = dotsPool.makeSprite()
        easyDot.size = CGSize(width: 5, height: 5)
        easyDot.color = color
        easyDot.alpha = 0.85

        easyDot.position = penAbsolutePosition()
        rings[0].shapeNode.addChild(easyDot)

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

private extension ArenaScene {
    func penLength() -> CGFloat {
        guard let ix = topRingIx else { preconditionFailure("No pen?") }
        return rings[ix].penNode!.frame.size.width
    }

    func penAbsolutePosition() -> CGPoint {
        guard let ix = topRingIx else { preconditionFailure("No pen?") }
        let p = CGPoint(x: penLength(), y: 0)
        return rings[ix].penNode!.convert(p, to: rings[0].shapeNode)
    }

    func radiusOf(ring: SKShapeNode) -> CGFloat {
        ring.frame.size.width / 2
    }

    func radiusOf(ring: SKSpriteNode) -> CGFloat {
        ring.frame.size.width / 2
    }

    func shapeNodeRadius(ring: Int) -> CGFloat {
        rings[ring].shapeNode.frame.size.width / 2
    }

    func spinDuration(ring: Int) -> TimeInterval {
        rings[ring].radiusFraction / settings.rotationRateHertz
    }

    func trackPath(ring: Int) -> CGPath {
        rings[ring].trackPath!
    }

    func trackPathRadius(ring: Int) -> CGFloat {
        rings[ring].trackPath!.boundingBox.size.width / 2
    }
}
