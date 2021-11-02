// We are a way for the cosmos to know itself. -- C. Sagan

import Combine
import SwiftUI

class Settings: ObservableObject {
    @ClampValue(min: 0, max: 10) var penLengthFraction: Double = 1
    @ClampValue(min: 0, max: 1000) var rotationRateHertz: Double = 0.25
    @Published var rings = [Ring]()
    @Published var zoomLevel = 0.0

    static let ringLineWidth = CGFloat(1)
    static let pathFadeDurationSeconds = CGFloat(20)

    private var cancellers = [AnyCancellable]()

    init() {
        for _ in 0..<6 {
            rings.append(Ring(radiusFraction: 1))
        }
        _penLengthFraction.objectWillChange.sink {
            self.objectWillChange.send()
        }.store(in: &cancellers)
        _rotationRateHertz.objectWillChange.sink {
            self.objectWillChange.send()
        }.store(in: &cancellers)
    }
}
