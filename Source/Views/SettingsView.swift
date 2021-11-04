// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: Settings

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PlaybackControlsView()

            Divider()
                .padding(.bottom, 10)

            LayerScroller()
                .padding(.bottom, 10)
        }
        .frame(
            width: 300,
            alignment: .top
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(Settings())
    }
}
