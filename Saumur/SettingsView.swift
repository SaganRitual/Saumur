// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: Settings

    var penLengthString: String { String(format: "%.3f", settings.penLengthFraction) }
    var ring1RadiusString: String { String(format: "%.3f", settings.ring1RadiusFraction) }
    var rotationRateString: String { String(format: "%.3f", settings.rotationRateHertz) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Stepper("Pen length: \(penLengthString)", value: $settings.penLengthFraction)
                .padding(.top, 10)

            Stepper("Rotation rate: \(rotationRateString)", value: $settings.rotationRateHertz)

            ForEach(1..<2) { ringix in
                DisclosureGroup("Ring \(ringix)") {
                    Stepper("Ring1 radius: \(rotationRateString)", value: $settings.ring1RadiusFraction)
                }
            }
        }
        .padding([.bottom, .leading], 5)
        .frame(width: 300)
    }
}

struct SettingsView_Previews: PreviewProvider {
    @StateObject static var settings = Settings()

    static var previews: some View {
        SettingsView(settings: settings)
    }
}
