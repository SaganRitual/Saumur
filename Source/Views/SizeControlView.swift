// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct SizeControlView: View {
    @EnvironmentObject var settings: Settings

    var body: some View {
        VStack {
            HStack {
                Text("Spacer").font(.body)
                    .frame(minWidth: 100, alignment: .leading)

                Slider(
                    value: $settings.rotationRateHertz,
                    in: 0...10
                )
                .padding(.trailing)
            }

            HStack {
                Text("Pen").font(.body)
                    .frame(minWidth: 100, alignment: .leading)

                Slider(
                    value: $settings.rotationRateHertz,
                    in: 0...10
                )
                .padding(.trailing)
            }
        }
    }
}

struct SizeControlView_Previews: PreviewProvider {
    static var previews: some View {
        SizeControlView()
            .environmentObject(Settings())
    }
}
