// We are a way for the cosmos to know itself. -- C. Sagan

import Cocoa
import Foundation

func Gergely() -> NSRect {
    // Count initial frame
    let newFrame: NSRect
    if let screenFrame = NSScreen.main?.visibleFrame {
        // We got the screen dimensions, count the frame from them
        // visibleFrame is the screen size excluding menu bar (on top of the screen)
        // and dock (by default on bottom)
        let newWidth = screenFrame.width * 0.95
        let newHeight = newWidth / Config.aspectRatioOfRobsMacbookPro
        let newSize = NSSize(width: newWidth, height: newHeight)

        let newOrigin = CGPoint(x: screenFrame.origin.x + (screenFrame.width  - newSize.width),
                                y: screenFrame.origin.y + (screenFrame.height - newSize.height))
        newFrame = NSRect(origin: newOrigin, size: newSize)
    } else {
        // We have no clue about scren dimensions, set static size
        newFrame = NSRect(origin: NSPoint(x: 50, y: 100), size: NSSize(width: 1500, height: 850))
    }

    return newFrame
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let newFrame = Gergely()

        // Create the window and set the content view.
        window = NSWindow(
            contentRect: newFrame,
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )

        window.center()
        window.title = "C5"
        window.setFrameAutosaveName("C5")
        window.contentView = NSApp.mainWindow?.contentView
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
