//
//  Extensions.swift
//  Saumur
//
//  Created by Pham Thang on 30/10/2021.
//

import DispatchIntrospection
import SwiftUI

extension Double {
    var asPropertyDisplayText: String {
        String(format: "%.3f", self)
    }
}

/// remove List's background
extension NSTableView {
  open override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()

    backgroundColor = NSColor.clear
    enclosingScrollView!.drawsBackground = false
  }
}

struct IdentifiableIndices<Base: RandomAccessCollection>
    where Base.Element: Identifiable {

    typealias Index = Base.Index

    struct Element: Identifiable {
        let id: Base.Element.ID
        let rawValue: Index
    }

    fileprivate var base: Base
}

extension IdentifiableIndices: RandomAccessCollection {
    var startIndex: Index { base.startIndex }
    var endIndex: Index { base.endIndex}

    subscript(position: Index) -> Element {
        Element(id: base[position].id, rawValue: position)
    }

    func index(before index: Index) -> Index {
        base.index(before: index)
    }

    func index(after index: Index) -> Index {
        base.index(after: index)
    }
}

extension RandomAccessCollection where Element: Identifiable {
    var identifiableIndices: IdentifiableIndices<Self> {
        IdentifiableIndices(base: self)
    }
}

extension ForEach where ID == Data.Element.ID,
                        Data.Element: Identifiable,
                        Content: View {
    init<T>(
        _ indices: Data,
        @ViewBuilder content: @escaping (Data.Index) -> Content
    ) where Data == IdentifiableIndices<T> {
        self.init(indices) { index in
            content(index.rawValue)
        }
    }
}
