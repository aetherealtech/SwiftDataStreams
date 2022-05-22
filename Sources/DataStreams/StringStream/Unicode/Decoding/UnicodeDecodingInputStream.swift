//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation

class UnicodeDecodeError : Error {

}

extension InputStream where Datum == Unicode.UTF8.CodeUnit {

    func utf8String() -> UnicodeDecodingInputStream<Unicode.UTF8> {

        UnicodeDecodingInputStream(source: self)
    }
}

extension InputStream where Datum == Unicode.UTF16.CodeUnit {

    func utf16String() -> UnicodeDecodingInputStream<Unicode.UTF16> {

        UnicodeDecodingInputStream(source: self)
    }
}

extension InputStream where Datum == Unicode.UTF32.CodeUnit {

    func utf32String() -> UnicodeDecodingInputStream<Unicode.UTF32> {

        UnicodeDecodingInputStream(source: self)
    }
}

class UnicodeDecodingInputStream<Codec: UnicodeCodec> : InputStream {

    typealias Datum = Character

    convenience init<Source: InputStream>(
        source: Source
    ) where Codec == Unicode.UTF8, Source.Datum == Codec.CodeUnit {

        self.init(
            source: source,
            codec: Unicode.UTF8()
        )
    }

    convenience init<Source: InputStream>(
        source: Source
    ) where Codec == Unicode.UTF16, Source.Datum == Codec.CodeUnit {

        self.init(
            source: source,
            codec: Unicode.UTF16()
        )
    }

    convenience init<Source: InputStream>(
        source: Source
    ) where Codec == Unicode.UTF32, Source.Datum == Codec.CodeUnit {

        self.init(
            source: source,
            codec: Unicode.UTF32()
        )
    }

    init<Source: InputStream>(
        source: Source,
        codec: Codec
    ) where Source.Datum == Codec.CodeUnit {

        self.source = source.erase()
        self.codec = codec
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

        while buffer.count < bufferSize {
            guard try await source.hasMore() else { break }
            buffer.append(try await source.read())
        }

        let result = self.codec.decode(&buffer)

        switch result {

        case .scalarValue(let value):
            return Character(value)

        case .emptyInput:
            return nil

        case .error:
            throw UnicodeDecodeError()
        }
    }

    private var bufferSize: Int { 4 / MemoryLayout<Codec.CodeUnit>.size }

    private let source: AnyInputStream<Codec.CodeUnit>
    private var codec: Codec

    private var buffer = Buffer<Codec.CodeUnit>()
    private var nextCharacter: Character?
}
