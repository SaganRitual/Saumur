//
//  ClampValue.swift
//  Saumur
//
//  Created by Pham Thang on 30/10/2021.
//

import Combine
import SwiftUI

@propertyWrapper
class ClampValue<T: Comparable>: ObservableObject {
    private let min: T
    private let max: T
    @Published var value: T
    var wrappedValue: T {
        get { return value }
        set {
            value = clamp(newValue)
            subject.send(value)
        }
    }
    init(initValue: T, min: T, max: T) {
        self.min = min
        self.max = max
        self.value = initValue
        self.wrappedValue = initValue
    }
    private lazy var subject = CurrentValueSubject<T, Error>(wrappedValue)
    var projectedValue: AnyPublisher<T, Error> {
        return subject.eraseToAnyPublisher()
    }
    func clamp(_ value: T) -> T {
        let clampingFunction = { ($0...$0).clamped(to: self.min...self.max).lowerBound }
        return clampingFunction(value)
    }
}
