// We are a way for the cosmos to know itself. -- C. Sagan

import SpriteKit
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var settings: Settings
    
    var body: some View {
        HStack(alignment: .top) {
            SettingsView()
                .frame(width: nil, height: arenaHeight, alignment: .top)

            SpriteView(scene:
                        ArenaScene(settings: settings, size: CGSize(width: arenaWidth, height: arenaHeight))
            )
            .padding(5)
            .frame(width: arenaWidth, height: arenaHeight)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Settings())
    }
}
