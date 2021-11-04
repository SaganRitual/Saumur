// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct LayerControlsView: View {
    @EnvironmentObject var settings: Settings

    let layerIx: Int

    var body: some View {
        VStack {
            Divider()
            
            Text("Layer \(layerIx)")
                .font(.title2)
                .foregroundColor(Color(NSColor.windowFrameTextColor))
                .padding(.top, 10)
                .padding(.bottom, -10)

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
