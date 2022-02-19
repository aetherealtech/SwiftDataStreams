//
// Created by Daniel Coleman on 11/19/21.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class Buffer<Element> : Sequence, IteratorProtocol {

    typealias Iterator = Buffer<Element>

    var isEmpty: Bool {

        data.isEmpty
    }

    var count: Int {

        data.count
    }

    func append(_ element: Element) {

        data.insert(element, at: 0)
    }

    func makeIterator() -> Iterator {

        self
    }

    func next() -> Element? {

        data.popLast()
    }

    private var data: [Element] = []
}
