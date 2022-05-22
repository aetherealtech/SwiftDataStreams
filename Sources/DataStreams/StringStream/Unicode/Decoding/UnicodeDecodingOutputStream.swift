//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation

extension OutputStream where Datum == UnicodeScalar {

    public func utf8CodePoints() -> AnyOutputStream<UTF8.CodeUnit> {

        UnicodeDecodingOutputStream(dest: self)
            .erase()
    }

    public func utf16CodePoints() -> AnyOutputStream<UTF16.CodeUnit> {

        UnicodeDecodingOutputStream(dest: self)
            .erase()
    }

    public func utf32CodePoints() -> AnyOutputStream<UTF32.CodeUnit> {

        UnicodeDecodingOutputStream(dest: self)
            .erase()
    }
}

extension OutputStream where Datum == Character {

    public func utf8CodePoints() -> AnyOutputStream<UTF8.CodeUnit> {

        self
            .unicodeScalars()
            .utf8CodePoints()
    }

    public func utf16CodePoints() -> AnyOutputStream<UTF16.CodeUnit> {

        self
            .unicodeScalars()
            .utf16CodePoints()
    }

    public func utf32CodePoints() -> AnyOutputStream<UTF32.CodeUnit> {

        self
            .unicodeScalars()
            .utf32CodePoints()
    }
}

class UnicodeDecodingOutputStream<Codec: UnicodeCodec> : OutputStream {

    typealias Datum = Codec.CodeUnit

    convenience init<Source: OutputStream>(
        dest: Source
    ) where Codec == Unicode.UTF8, Source.Datum == UnicodeScalar {

        self.init(
            dest: dest,
            codec: Unicode.UTF8()
        )
    }

    convenience init<Source: OutputStream>(
        dest: Source
    ) where Codec == Unicode.UTF16, Source.Datum == UnicodeScalar {

        self.init(
            dest: dest,
            codec: Unicode.UTF16()
        )
    }

    convenience init<Source: OutputStream>(
        dest: Source
    ) where Codec == Unicode.UTF32, Source.Datum == UnicodeScalar {

        self.init(
            dest: dest,
            codec: Unicode.UTF32()
        )
    }

    init<Source: OutputStream>(
        dest: Source,
        codec: Codec
    ) where Source.Datum == UnicodeScalar {

        self.dest = dest.erase()
        self.codec = codec
    }

    func write(_ datum: Codec.CodeUnit) async throws {

        buffer.append(datum)

        guard buffer.count == bufferSize else {
            return
        }

        try await writeBuffer()
    }

    func flush() async throws {

        while !buffer.isEmpty {
            try await writeBuffer()
        }

        try await dest.flush()
    }

    private var bufferSize: Int { 4 / MemoryLayout<Codec.CodeUnit>.size }

    private let dest: AnyOutputStream<UnicodeScalar>
    private var codec: Codec

    private var buffer = Buffer<Codec.CodeUnit>()

    private func writeBuffer() async throws {

        let result = self.codec.decode(&buffer)

        switch result {

        case .scalarValue(let value):
            try await dest.write(value)

        case .emptyInput:
            break

        case .error:
            throw UnicodeDecodeError()
        }
    }
}
