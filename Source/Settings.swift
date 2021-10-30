// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SwiftUI

class Settings: ObservableObject {
    @ClampValue(initValue: 1, min: 0, max: 10) var penLengthFraction: Double
    @ClampValue(initValue: 0.25, min: 0, max: 1000) var rotationRateHertz: Double
    @Published var ring1RadiusFraction = 1.0
    @Published var zoomLevel = 0.0

    static let ringLineWidth = CGFloat(1)
    static let pathFadeDurationSeconds = CGFloat(20)

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
