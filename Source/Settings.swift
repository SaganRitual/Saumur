// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

class Settings: ObservableObject {
    @Published var penLengthFraction = 0.85
    @Published var rotationRateHertz = 0.1
    @Published var ring1RadiusFraction = 0.4
    @Published var zoomLevel = 0.0

    static let ringLineWidth = CGFloat(0.1)
    static let pathFadeDurationSeconds = CGFloat(20)
}
