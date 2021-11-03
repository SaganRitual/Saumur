// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: Settings

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PlaybackControlsView()

            LayerControlView()
        }
        .frame(
            minWidth: 300, idealWidth: 300, maxWidth: nil,
            minHeight: nil, idealHeight: nil, maxHeight: .infinity,
            alignment: .top
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(Settings())
    }
}
