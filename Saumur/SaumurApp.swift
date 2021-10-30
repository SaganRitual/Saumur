// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

let arenaWidth = 0.75 * NSScreen.main!.frame.size.height
let arenaHeight = 0.75 * NSScreen.main!.frame.size.height

var arenaScene: ArenaScene!

@main
struct SaumurApp: App {
    @StateObject var settings = Settings()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(settings)
        }
    }
}
