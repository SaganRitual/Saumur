// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: Settings

    var penLengthString: String { String(format: "%.3f", settings.penLengthFraction) }
    var ring1RadiusString: String { String(format: "%.3f", settings.ring1RadiusFraction) }
    var rotationRateString: String { String(format: "%.3f", settings.rotationRateHertz) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZoomSliderView(settings: settings)
            .padding(.top, 10)
            .padding([.leading, .trailing], 10)

            Divider().background(Color.black).padding([.top, .bottom], -5)

            Stepper("Pen: \(penLengthString)", value: $settings.penLengthFraction)

            Divider().background(Color.black).padding([.top, .bottom], -5)

            Stepper("Rotation: \(rotationRateString)", value: $settings.rotationRateHertz)

            ForEach(1..<2) { ringix in
                VStack {
                    Divider().background(Color.black).padding(.bottom, -5)

                    DisclosureGroup("Ring \(ringix)") {
                        Stepper("Radius: \(rotationRateString)", value: $settings.ring1RadiusFraction)
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
    @StateObject static var settings = Settings()

    static var previews: some View {
        SettingsView(settings: settings)
    }
}
