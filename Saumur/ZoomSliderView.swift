// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct ZoomSliderView: View {
    @ObservedObject var settings: Settings
    @State var isEditing = false

    var body: some View {
        VStack {
            Text("Zoom").padding(.bottom, -10)

            Slider(
                value: $settings.zoomLevel,
                in: 0...1,
                onEditingChanged: { editing in
                    isEditing = editing
                }
            )
        }
        .padding(.top, 10)
        .padding([.leading, .trailing], 30)
    }
}

struct ZoomSliderView_Previews: PreviewProvider {
    @StateObject static var settings = Settings()

    static var previews: some View {
        ZoomSliderView(settings: settings)
    }
}
