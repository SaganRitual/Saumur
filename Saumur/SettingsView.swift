// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct SettingsView: View {
    @State private var penLengthFraction = Double(1.0)
    @State private var rotationRateHertz = Double(1.0)
    @State private var ring1RadiusFraction = Double(0.75)

    var penLengthString: String { String(format: "%.3f", penLengthFraction) }
    var ring1RadiusString: String { String(format: "%.3f", ring1RadiusFraction) }
    var rotationRateString: String { String(format: "%.3f", rotationRateHertz) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Stepper("Pen length: \(penLengthString)", value: $penLengthFraction)
                .padding(.top, 10)

            Stepper("Rotation rate: \(rotationRateString)", value: $rotationRateHertz)

            ForEach(1..<2) { ringix in
                DisclosureGroup("Ring \(ringix)") {
                    Stepper("Ring1 radius: \(rotationRateString)", value: $ring1RadiusFraction)
                }
            }
        }
        .padding([.bottom, .leading], 5)
//        .background(Color.green.opacity(0.3))
        .frame(width: 300)
    }
}

struct NavigationView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
