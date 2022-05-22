//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation

public class UnicodeEncodeError : Error {

}

extension InputStream where Datum == UnicodeScalar {

    public func utf8CodePoints() -> AnyInputStream<UTF8.CodeUnit> {

        UnicodeEncodingInputStream<UTF8>(source: self)
            .erase()
    }

    public func utf16CodePoints() -> AnyInputStream<UTF16.CodeUnit> {

        UnicodeEncodingInputStream<UTF16>(source: self)
            .erase()
    }

    public func utf32CodePoints() -> AnyInputStream<UTF32.CodeUnit> {

        UnicodeEncodingInputStream<UTF32>(source: self)
            .erase()
    }
}

extension InputStream where Datum == Character {

    public func utf8CodePoints() -> AnyInputStream<UTF8.CodeUnit> {

        self
            .unicodeScalars()
            .utf8CodePoints()
    }

    public func utf16CodePoints() -> AnyInputStream<UTF16.CodeUnit> {

        self
            .unicodeScalars()
            .utf16CodePoints()
    }

    public func utf32CodePoints() -> AnyInputStream<UTF32.CodeUnit> {

        self
            .unicodeScalars()
            .utf32CodePoints()
    }
}

class UnicodeEncodingInputStream<Codec: UnicodeCodec> : InputStream {

    typealias Datum = Codec.CodeUnit

    init<Source: InputStream>(
        source: Source
    ) where Source.Datum == UnicodeScalar {

        self.source = source.erase()
    }

    func hasMore() async throws -> Bool {

        if current.position < current.characters.count {
            return true
        }

        return try await source.hasMore()
    }

    func read() async throws -> Codec.CodeUnit {

        if current.position == current.characters.count {

            try await readNextCharacter()
        }

        let result = current.characters[current.position]
        current.position = current.position + 1

        return result
    }

    func skip(count: Int) async throws -> Int {

        let skipped = Swift.min(count, current.characters.count - current.position)
        current.position += skipped

        let remaining = count - skipped
        guard remaining > 0 else {
            return skipped
        }

        try await readNextCharacter()
        return skipped + (try await skip(count: remaining))
    }

    private func readNextCharacter() async throws {

        let scalar = try await source.read()

        guard let encoded = Codec.encode(scalar) else {
            throw UnicodeEncodeError()
        }

        current.characters = [Codec.CodeUnit](encoded)
        current.position = 0
    }

    private class Current {

        init() {

            self.characters = [Codec.CodeUnit]()
            self.position = 0
        }

        var characters: [Codec.CodeUnit]
        var position: Int
    }

    private let source: AnyInputStream<UnicodeScalar>
    private let current = Current()
}
