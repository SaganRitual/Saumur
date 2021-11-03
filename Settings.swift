// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SwiftUI

class Settings: ObservableObject {
    @ClampValue(initValue: 0.25, min: 0, max: 5) var simulationSpeed: Double
    @ClampValue(initValue: 0.75, min: 0, max: 10) var penLengthFraction: Double
    @ClampValue(initValue: 1.00, min: 0, max: 10) var rotationRateHertz: Double

    @Published var ringRadiiFractions = [0.95, 0.2, 0.3, 0.2]
    @Published var ringColors: [NSColor] = [.clear, .clear, .clear, .clear]
    @Published var showPen = true
    @Published var showRings = true
    @Published var showTracks = true
    @Published var zoomLevel = 0.0

    static let ringLineWidth = CGFloat(0.1)
    static let pathFadeDurationSeconds = CGFloat(5)

    private var cancellers = [AnyCancellable]()

    init() {
        _penLengthFraction.objectWillChange.sink {
            self.objectWillChange.send()
        }.store(in: &cancellers)
        _rotationRateHertz.objectWillChange.sink {
            self.objectWillChange.send()
        }.store(in: &cancellers)
    }
}
