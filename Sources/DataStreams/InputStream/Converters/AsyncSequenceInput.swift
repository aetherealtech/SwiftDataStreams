//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

import CoreExtensions

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension AsyncSequence {

    func asStream() -> AnyInputStream<Element> {

        AsyncSequenceInputStream(source: self).erase()
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class AsyncSequenceInputStream<Source: AsyncSequence> : InputStream {

    typealias Datum = Source.Element

    init(source: Source) {

        current = source.makeAsyncIterator()
    }

    func hasMore() async throws -> Bool {

         (try? await getNext()) != nil
    }

    func read() async throws -> Datum {

        try await consumeNext()
    }

    func skip(count: Int) async throws -> Int {

        var remaining = count

        while remaining > 0 {
            _ = try await consumeNext()
            remaining -= 1
        }

        return count - remaining
    }

    func getNext() async throws -> Datum {

        guard let next = try await self.next ??= try await current.next() else {
            throw EndOfStreamError()
        }

        return next
    }
    
    func consumeNext() async throws -> Datum {

        let next = try await getNext()
        self.next = nil
        return next
    }
    
    var current: Source.AsyncIterator
    var next: Datum?
}