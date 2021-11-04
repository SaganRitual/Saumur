// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct LayerScroller: View {
    @EnvironmentObject var settings: Settings

    var body: some View {
        VStack {
            ForEach(0..<6) { layerIx in
                LayerControlsView(layerIx: layerIx)
            }
        }
    }
}

struct LayerScroller_Previews: PreviewProvider {
    static var previews: some View {
        LayerScroller()
            .environmentObject(Settings())
    }
}
