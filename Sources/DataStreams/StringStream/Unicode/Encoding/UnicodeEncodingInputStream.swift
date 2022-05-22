//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation

class UnicodeEncodeError : Error {

}

extension InputStream where Datum == UnicodeScalar {

    func utf8CodePoints() -> UnicodeEncodingInputStream<Unicode.UTF8> {

        UnicodeEncodingInputStream(source: self)
    }

    func utf16CodePoints() -> UnicodeEncodingInputStream<Unicode.UTF16> {

        UnicodeEncodingInputStream(source: self)
    }

    func utf32CodePoints() -> UnicodeEncodingInputStream<Unicode.UTF32> {

        UnicodeEncodingInputStream(source: self)
    }
}

extension InputStream where Datum == Character {

    func utf8CodePoints() -> UnicodeEncodingInputStream<Unicode.UTF8> {

        self
            .unicodeScalars()
            .utf8CodePoints()
    }

    func utf16CodePoints() -> UnicodeEncodingInputStream<Unicode.UTF16> {

        self
            .unicodeScalars()
            .utf16CodePoints()
    }

    func utf32CodePoints() -> UnicodeEncodingInputStream<Unicode.UTF32> {

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
