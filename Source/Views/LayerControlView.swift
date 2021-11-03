// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct LayerControlView: View {
    @EnvironmentObject var settings: Settings

    @State var joint = true
    @State var pen = true
    @State var penTip = true
    @State var ring = true
    @State var spacer = true

    var body: some View {
        ZStack {
            VStack {
                Text("Layer")
                    .font(.title)
                    .foregroundColor(Color(NSColor.windowFrameTextColor))

                HStack {
                    VStack {
                        Text("Visibility")
                            .font(.title)
                            .foregroundColor(Color(NSColor.windowFrameTextColor))
                            .padding(.bottom, 25)

                        VisibilityControlView(checked: $joint, label: "Joints")
                        VisibilityControlView(checked: $pen, label: "Pen")
                        VisibilityControlView(checked: $penTip, label: "Pen tip")
                        VisibilityControlView(checked: $ring, label: "Ring")
                        VisibilityControlView(checked: $spacer, label: "Spacer")
                    }

                    VStack {
                        Text("Size")
                            .font(.title)
                            .foregroundColor(Color(NSColor.windowFrameTextColor))

                        SizeControlView()
                    }

                    VStack {
                        Text("Color")
                            .font(.title)
                            .foregroundColor(Color(NSColor.windowFrameTextColor))
                    }
                }
                .padding([.leading, .trailing], 25)
                .padding(.top, 10)
            }
        }
    }
}

struct LayerControlView_Previews: PreviewProvider {
    static var previews: some View {
        LayerControlView().environmentObject(Settings())
    }
}
