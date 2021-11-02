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

            List {
                ForEach(settings.rings.identifiableIndices) { index in
                    if (index != settings.rings.count - 1) { // avoid crash on last element deleting [swiftui bug]
                        VStack {
                            ScrollView {
                                Divider().background(Color.black).padding(.bottom, -5)
                                DisclosureGroup(isExpanded: $settings.rings[index].expandable) {
                                    Stepper("Radius: \(settings.rings[index].radiusFraction.asPropertyDisplayText)", value: $settings.rings[index].radiusFraction)
                                } label: {
                                    Text("Ring \(index)")
                                }
                            }
                        }
                    }
                }.onDelete { indexSet in
                    settings.rings.remove(atOffsets: indexSet)
                }
            }
            Spacer()
            HStack {
                Spacer()
                Button {
                    settings.rings.append(Ring(radiusFraction: 1.0))
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 44, height: 44)
                }.frame(width: 100, height: 60, alignment: .center)
                Spacer()
            }.frame(height: 44)
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
