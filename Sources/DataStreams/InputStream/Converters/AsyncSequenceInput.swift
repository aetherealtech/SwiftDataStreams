//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

import CoreExtensions

extension AsyncSequence {

    public func asStream() -> AnyInputStream<Element> {

        AsyncSequenceInputStream(source: self)
            .erase()
    }
}

class AsyncSequenceInputStream<Source: AsyncSequence> : InputStream {

    typealias Datum = Source.Element

    init(source: Source) {

        current = source.makeAsyncIterator()
    }

    func hasMore() async throws -> Bool {

        do {

            _ = try await getNext()
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

        guard let next = await self.next ??= await fetchNext() else {
            throw EndOfStreamError()
        }

        switch next {

        case .success(let value):
            return value

        case .failure(let error):
            throw error
        }
    }

    func consumeNext() async throws -> Datum {

        let next = try await getNext()
        self.next = nil
        return next
    }

    func fetchNext() async -> Result<Datum, Error>? {

        do {

            guard let next = try await current.next() else {
                return nil
            }

            return .success(next)

        } catch(let error) {

            return .failure(error)
        }
    }

    var current: Source.AsyncIterator
    var next: Result<Datum, Error>?
}
