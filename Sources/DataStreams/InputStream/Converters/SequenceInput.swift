//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

import CoreExtensions

extension Sequence {

    @available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
    func asStream() -> AnyInputStream<Element> {

        SequenceInputStream(source: self).erase()
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class SequenceInputStream<Source: Sequence> : InputStream {

    typealias Datum = Source.Element

    init(source: Source) {

        current = source.makeIterator()
    }

    func hasMore() async throws -> Bool {

        do {

            _ = try getNext()
            return true

        } catch(let error) {

            switch(error) {

            case is EndOfStreamError:
                return false

            default:
                throw error
            }
        }
    }

    func read() async throws -> Datum {

        try consumeNext()
    }

    func skip(count: Int) async throws -> Int {

        var remaining = count

        while remaining > 0 {
            _ = try consumeNext()
            remaining -= 1
        }

        return count - remaining
    }

    func getNext() throws -> Datum {

        guard let next = self.next ??= current.next() else {
            throw EndOfStreamError()
        }

        return next
    }
    
    func consumeNext() throws -> Datum {

        let next = try getNext()
        self.next = nil
        return next
    }
    
    var current: Source.Iterator
    var next: Datum?
}
