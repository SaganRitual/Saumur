import SpriteKit

/**
 Executes work items in the scene's update context This lets us schedule
 stuff to run on the next scene update, on the main thread
*/
class SceneDispatch {
    private let lockQueue = DispatchQueue(
        label: "ak.scene.q",
        target: DispatchQueue.global()
    )

    struct WorkItem {
        let interval: Int?
        let name: String
        let workFunction: () -> Void

        init(
            interval: Int? = nil,
            workFunction: @escaping () -> Void,
            name: String
        ) {
            self.interval = interval
            self.name = name
            self.workFunction = workFunction
        }
    }

    private var workItems = Deque<WorkItem>(cElements: 1000)
    private var recurringItems = Deque<WorkItem>(cElements: 100)

    static let one_ms = UInt64(1e6)
    let warningDuration = SceneDispatch.one_ms * 10
    let overloadDuration = SceneDispatch.one_ms * 15
}

extension SceneDispatch {
    func recur(
        name: String,
        interval inTicks: Int = 60,
        workFunction: @escaping () -> Void
    ) {
        lockQueue.async {
            self.recurringItems.pushBack(
                WorkItem(interval: inTicks, workFunction: workFunction, name: name)
            )
        }
    }

    func schedule(name: String, _ workFunction: @escaping () -> Void) {
        lockQueue.async {
            self.workItems.pushBack(WorkItem(workFunction: workFunction, name: name))
        }
    }
}

extension SceneDispatch {
    func tick(_ tickCount: Int) {
        lockQueue.sync { self.tick_(tickCount) }
    }

    func tick_(_ tickCount: Int) {
        assert(Display.displayCycle == .updateStarted)

        let start = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)

        for item in recurringItems.elements where (tickCount % item!.interval!) == 0 {
            item!.workFunction()
            if !isDurationOk(from: start, task: "recur") { return }
        }

        while !workItems.isEmpty {
            let workItem = workItems.popFront()
            workItem.workFunction()
            if !isDurationOk(from: start, task: "single-dispatch") {
                return
            }
        }
    }

    private func isDurationOk(
        from startTime: UInt64, task: String
    ) -> Bool {
        let duration = clock_gettime_nsec_np(CLOCK_UPTIME_RAW) - startTime

        if duration > overloadDuration { return false }

        return true
    }
}
