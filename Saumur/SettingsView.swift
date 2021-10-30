// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: Settings
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZoomSliderView()
            .padding(.top, 10)
            .padding([.leading, .trailing], 10)

            Divider().background(Color.black).padding([.top, .bottom], -5)

            Stepper("Pen: \(settings.penLengthFraction.asPropertyDisplayText)", value: $settings.penLengthFraction)

            Divider().background(Color.black).padding([.top, .bottom], -5)

            Stepper("Rotation: \(settings.rotationRateHertz.asPropertyDisplayText)", value: $settings.rotationRateHertz)

            ForEach(1..<2) { ringix in
                VStack {
                    Divider().background(Color.black).padding(.bottom, -5)

                    DisclosureGroup("Ring \(ringix)") {
                        Stepper("Radius: \(settings.ring1RadiusFraction.asPropertyDisplayText)", value: $settings.ring1RadiusFraction)
                    }
                }
            }

            Divider().background(Color.black).padding([.top, .bottom], -5)
        }
        .padding(10)
        .frame(
            minWidth: 300, idealWidth: 300, maxWidth: nil,
            minHeight: nil, idealHeight: nil, maxHeight: .infinity,
            alignment: .top
        )
        .border(Color.black)
        .background(Color.yellow.opacity(0.5))
    }
}

struct SettingsView_Previews: PreviewProvider {
    @StateObject var settings = Settings()

    static var previews: some View {
        SettingsView()
    }
}
