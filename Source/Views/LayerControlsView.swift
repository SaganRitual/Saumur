// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct LayerControlsView: View {
    @EnvironmentObject var settings: Settings

    let layerIx: Int

    var body: some View {
        VStack {
            Text("Layer \(layerIx)")
                .font(.title)
                .foregroundColor(Color(NSColor.windowFrameTextColor))

            Spacer()

            SizeControlView()
                .frame(
                    minWidth: nil, idealWidth: nil, maxWidth: 400,
                    minHeight: nil, idealHeight: nil, maxHeight: 400
                )
                .padding()

            VisibilityView()
        }
    }
}

struct LayerControlsView_Previews: PreviewProvider {
    static var previews: some View {
        LayerControlsView(layerIx: 42).environmentObject(Settings())
    }
}
