// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit
import SwiftUI

let arenaScene = ArenaScene(size: NSScreen.main!.frame.size * 0.5)

@main
struct SaumurApp: App {
    var body: some Scene {
        WindowGroup {
            SpriteView(scene: arenaScene)
                .padding(8)
                .background(Color.yellow.opacity(0.85))
                .aspectRatio(
                    Config.aspectRatioOfRobsMacbookPro, contentMode: .fit
                )
                .frame(
                    width: Config.sceneWidthPix,
                    height: Config.sceneWidthPix * Config.xScaleToSquare
                )
                .frame(
                    minWidth: Config.sceneWidthPix,
                    maxWidth: .infinity,
                    minHeight: Config.sceneWidthPix * Config.xScaleToSquare,
                    maxHeight: .infinity
                )
        }
    }
}
