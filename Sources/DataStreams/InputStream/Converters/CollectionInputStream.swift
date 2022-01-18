//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Collection {

    public func asStream() -> CollectionInputStream<Self> {

        CollectionInputStream<Self>(source: self)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public class CollectionInputStream<Source: Collection> : SeekableInputStream {

    public typealias Datum = Source.Element

    init(source: Source) {

        data = source
        currentIndex = data.startIndex
    }

    public func hasMore() async throws -> Bool {

        position < data.count
    }

    public func read() async throws -> Datum {

        guard currentIndex != data.endIndex else {
            throw EndOfStreamError()
        }
        
        let result = data[currentIndex]
        advance(1)

        return result
    }

    public var position: Int {

        data.distance(from: data.startIndex, to: currentIndex)
    }

    public func seek(position: Int) async throws -> Bool {

        guard (0..<data.count).contains(position) else {
            return false
        }

        let offset = position - sourcePosition
        advance(offset)
        return true
    }

    public internal(set) var data: Source

    var sourcePosition: Int {

        data.distance(from: data.startIndex, to: currentIndex)
    }

    func advance(_ count: Int) {

        data.formIndex(&currentIndex, offsetBy: count)
    }

    var currentIndex: Source.Index
}
