// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct PlaybackControlsView: View {
    @EnvironmentObject var settings: Settings

    @State private var number = 1.0

    var displayHz: String {
        String(format: "Rate %0.2fHz", number)
    }

    var body: some View {
        VStack {
            Text(displayHz)
                .font(.title)
                .foregroundColor(Color(NSColor.windowFrameTextColor))

            HStack {
                Image(systemName: "stop.fill")
                Image(systemName: "play.fill")

                Slider(
                    value: $settings.rotationRateHertz,
                    in: 0...10
                )
                .padding([.leading, .trailing], 25)
                .onAppear(perform: { self.number = settings.rotationRateHertz })
            }
            .font(.largeTitle)
            .padding()
        }
    }
}

struct PlaybackControlsView_Previews: PreviewProvider {
    static let settings = Settings()

    static var previews: some View {
        PlaybackControlsView()
            .environmentObject(settings)
    }
}
