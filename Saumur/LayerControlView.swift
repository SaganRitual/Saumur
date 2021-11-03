// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct LayerControlView: View {
    @State var joint = true
    @State var pen = true
    @State var penTip = true
    @State var ring = true
    @State var spacer = true

    var body: some View {
        ZStack {
            Color(NSColor.underPageBackgroundColor)

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

                        CheckBoxView(checked: $joint, label: "Joints")
                        CheckBoxView(checked: $pen, label: "Pen")
                        CheckBoxView(checked: $penTip, label: "Pen tip")
                        CheckBoxView(checked: $ring, label: "Ring")
                        CheckBoxView(checked: $spacer, label: "Spacer")
                    }

                    VStack {
                        Text("Size")
                            .font(.title)
                            .foregroundColor(Color(NSColor.windowFrameTextColor))
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
        LayerControlView()
    }
}
