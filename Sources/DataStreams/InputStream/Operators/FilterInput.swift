//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

extension InputStream {

    public func filterIn(_ condition: @escaping (Datum) async throws -> Bool) -> AnyInputStream<Datum> {

        FilteredInputStream(
            source: self,
            condition: condition
        ).erase()
    }
}

class FilteredInputStream<Datum> : InputStream {

    init<SourceStream: InputStream>(
        source: SourceStream,
        condition: @escaping (Datum) async throws -> Bool
    ) where SourceStream.Datum == Datum {

        self.source = source.erase()
        self.condition = condition
    }

    func hasMore() async throws -> Bool {

        if next != nil {
            return true
        }
        if try await readAhead() != nil {
            return true
        }
        return false
    }

    func read() async throws -> Datum {

        if let next = self.next {

            self.next = nil
            return next
        }

        guard let next = try await readAhead() else {

            throw EndOfStreamError()
        }

        return next
    }

    func skip(count: Int) async throws -> Int {

        for skipped in 0..<count {

            guard try await readAhead() != nil else {

                break
            }
        }

        next = nil
        return count
    }

    private func readAhead() async throws -> Datum? {

        while try await source.hasMore() {

            let peek = try await source.read()

            if try await condition(peek) {
                next = peek
                return peek
            }
        }

        return nil
    }

    private let source: AnyInputStream<Datum>
    private var next: Datum?

    private let condition: (Datum) async throws -> Bool
}