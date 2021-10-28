// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit
import SwiftUI

struct ContentView: View {
    @StateObject var settings = Settings()

    var body: some View {
        HStack(alignment: .top) {
            SettingsView(settings: settings)
                .frame(width: nil, height: arenaHeight, alignment: .top)

            SpriteView(scene:
                ArenaScene(
                    settings: settings,
                    size: CGSize(width: arenaWidth, height: arenaHeight)
                )
            )
            .padding(5)
            .background(Color.yellow.opacity(0.85))
            .frame(width: arenaWidth, height: arenaHeight)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
