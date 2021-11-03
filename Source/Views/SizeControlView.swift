// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct SizeControlView: View {
    @EnvironmentObject var settings: Settings

    var body: some View {
        VStack {
            Text("Spacer length").font(.title)

            Slider(
                value: $settings.rotationRateHertz,
                in: 0...10
            )

            Text("Pen length").font(.title)

            Slider(
                value: $settings.rotationRateHertz,
                in: 0...10
            )
        }
    }
}

struct SizeControlView_Previews: PreviewProvider {
    static var previews: some View {
        SizeControlView()
            .environmentObject(Settings())
    }
}
