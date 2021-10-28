// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

class Settings: ObservableObject {
    @Published var penLengthFraction = 1.0
    @Published var rotationRateHertz = 1.0
    @Published var ring1RadiusFraction = 1.0
    @Published var zoomLevel = 0.0

    static let ringLineWidth = CGFloat(1)
    static let pathFadeDurationSeconds = CGFloat(20)
}
