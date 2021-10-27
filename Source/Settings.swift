// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

class Settings: ObservableObject {
    @Published var penLengthFraction = Double(1.0)
    @Published var rotationRateHertz = Double(1.0)
    @Published var ring1RadiusFraction = Double(0.5)

    static let ringLineWidth = CGFloat(1)
    static let pathFadeDurationSeconds: CGFloat = 20
//
//    static let ring1DrawpointFraction: CGFloat = 1.7
//
//    static let speedHertz: CGFloat = 1
}
