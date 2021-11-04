// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct VisibilityView: View {
//    @EnvironmentObject var settings: Settings
    @State var joint = false
    @State var pen = false
    @State var penTip = false
    @State var ring = false
    @State var spacer = false
    @State var centers = false

    var body: some View {
        HStack {
            VStack {
                Text("Show")
                    .font(.title3)
                    .foregroundColor(Color(NSColor.windowFrameTextColor))
                    .padding(.top, -15)
                    .padding(.bottom, 5)

                HStack {
                    VStack(alignment: .leading) {
                        VisibilityControlView(checked: $joint, label: "Joints")
                        VisibilityControlView(checked: $pen, label: "Pen")
                        VisibilityControlView(checked: $penTip, label: "Pen tip")
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        VisibilityControlView(checked: $ring, label: "Ring")
                        VisibilityControlView(checked: $spacer, label: "Spacer")
                        VisibilityControlView(checked: $centers, label: "Centers")
                    }
                }
            }
        }
        .padding([.leading, .trailing], 25)
        .padding(.top, 10)
    }
}

struct VisibilityView_Previews: PreviewProvider {
    static var previews: some View {
        VisibilityView().environmentObject(Settings())
    }
}
