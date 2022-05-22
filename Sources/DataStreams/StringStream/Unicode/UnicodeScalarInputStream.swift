//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation

extension InputStream where Datum == UnicodeScalar {

    public func string() -> StringInputStream {

        UnicodeScalarInputStream(source: self)
            .erase()
    }
}

class UnicodeScalarInputStream : InputStream {

    typealias Datum = Character

    init<Source: InputStream>(
        source: Source
    ) where Source.Datum == UnicodeScalar {

        self.source = source.erase()
    }

    func hasMore() async throws -> Bool {

        if nextCharacter != nil {
            return true
        }
        nextCharacter = try await getNextCharacter()
        return nextCharacter != nil
    }

    func read() async throws -> Character {

        if let next = self.nextCharacter {
            self.nextCharacter = nil
            return next
        }

        guard let next = try await getNextCharacter() else {
            throw EndOfStreamError()
        }

        return next
    }

    func skip(count: Int) async throws -> Int {

        var skipped = 0

        while skipped < count {
            guard try await hasMore() else { break }
            _ = try await read()
            skipped += 1
        }

        return skipped
    }

    private func getNextCharacter() async throws -> Character? {

        var characters = String(String.UnicodeScalarView(buffer))

        while characters.count < 2 {
            guard try await source.hasMore() else { break }
            buffer.append(try await source.read())
            characters = String(String.UnicodeScalarView(buffer))
        }

        if !buffer.isEmpty {
            buffer.removeFirst(Swift.max(buffer.count - 1, 1))
        }

        return characters.first
    }

    private let source: AnyInputStream<UnicodeScalar>

    private var buffer = [UnicodeScalar]()
    private var nextCharacter: Character?
}
