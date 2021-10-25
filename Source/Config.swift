// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation

extension CGFloat {
    static let tau = 2 * CGFloat.pi
}

enum Config {
    static let aspectRatioOfRobsMacbookPro: CGFloat = 2880 / 1800
    static let sceneWidthPix: CGFloat = 950
    static let xScaleToSquare = 1 / aspectRatioOfRobsMacbookPro
}
