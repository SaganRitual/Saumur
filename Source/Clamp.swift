//
//  Clamp.swift
//  Saumur
//
//  Created by Pham Thang on 30/10/2021.
//

import Foundation

@propertyWrapper
class PublisherConvertible<T> {
    var wrappedValue: T {
        willSet {
            subject.send(newValue)
        }
    }
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
    }
    private lazy var subject = CurrentValueSubject<T, Error>(wrappedValue)
    var projectedValue: AnyPublisher<T, Error> {
        return subject.eraseToAnyPublisher()
    }
}
