// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit
import SwiftUI

let arenaWidth = 0.75 * NSScreen.main!.frame.size.height
let arenaHeight = 0.75 * NSScreen.main!.frame.size.height
let arenaScene = ArenaScene(size: CGSize(width: arenaWidth, height: arenaHeight))

@main
struct SaumurApp: App {
    var body: some Scene {
        WindowGroup {
            HStack {
                SettingsView()
//                Rectangle()
//                    .background(Color.blue.opacity(0.85))
//                    .foregroundColor(.clear)
//                    .frame(width: 0.4 * arenaWidth, height: arenaHeight)

                SpriteView(scene: arenaScene)
                    .padding(8)
                    .background(Color.yellow.opacity(0.85))
                    .frame(width: arenaWidth, height: arenaHeight)
            }
        }
    }
}
