// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: Settings

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PlaybackControlsView()

            Divider().background(Color.black).padding([.top, .bottom], -5)

            LayerControlView()

            Divider().background(Color.black).padding([.top, .bottom], -5)

            Stepper("Rotation: \(settings.rotationRateHertz.asPropertyDisplayText)", value: $settings.rotationRateHertz)

            ForEach(1..<2) { ringix in
                VStack {
                    Divider().background(Color.black).padding(.bottom, -5)

                    DisclosureGroup("Ring \(ringix)") {
                        Stepper(
                            "Radius: \(settings.ringRadiiFractions[1].asPropertyDisplayText)",
                            value: $settings.ringRadiiFractions[1])
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
