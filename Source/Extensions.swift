//
//  Extensions.swift
//  Saumur
//
//  Created by Pham Thang on 30/10/2021.
//

import Foundation

extension Double {
    var asPropertyDisplayText: String {
        String(format: "%.3f", self)
    }

    static let tau = 2 * Double.pi
}

extension CGFloat {
    static let tau = 2 * CGFloat.pi
}
