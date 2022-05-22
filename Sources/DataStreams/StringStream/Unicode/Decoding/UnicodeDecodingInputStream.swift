//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation

class UnicodeDecodeError : Error {

}

extension InputStream where Datum == Unicode.UTF8.CodeUnit {

    func utf8Scalars() -> UnicodeDecodingInputStream<Unicode.UTF8> {

        UnicodeDecodingInputStream(source: self)
    }

    func utf8String() -> InputStringStream {

        self.utf8Scalars()
            .string()
    }
}

extension InputStream where Datum == Unicode.UTF16.CodeUnit {

    func utf16Scalars() -> UnicodeDecodingInputStream<Unicode.UTF16> {

        UnicodeDecodingInputStream(source: self)
    }

    func utf16String() -> InputStringStream {

        self.utf16Scalars()
            .string()
    }
}

extension InputStream where Datum == Unicode.UTF32.CodeUnit {

    func utf32Scalars() -> UnicodeDecodingInputStream<Unicode.UTF32> {

        UnicodeDecodingInputStream(source: self)
    }

    func utf32String() -> InputStringStream {

        self.utf32Scalars()
            .string()
    }
}

class UnicodeDecodingInputStream<Codec: UnicodeCodec> : InputStream {

    typealias Datum = UnicodeScalar

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

        if nextScalar != nil {
            return true
        }
        nextScalar = try await getNextScalar()
        return nextScalar != nil
    }

    func read() async throws -> UnicodeScalar {

        if let next = self.nextScalar {
            self.nextScalar = nil
            return next
        }

        guard let next = try await getNextScalar() else {
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

    private func getNextScalar() async throws -> UnicodeScalar? {

        while buffer.count < bufferSize {
            guard try await source.hasMore() else { break }
            buffer.append(try await source.read())
        }

        let result = self.codec.decode(&buffer)

        switch result {

        case .scalarValue(let value):
            return value

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
    private var nextScalar: UnicodeScalar?
}
