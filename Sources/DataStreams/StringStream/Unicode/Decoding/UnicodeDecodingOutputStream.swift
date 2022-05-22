//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation

extension OutputStream where Datum == Character {

    func utf8String() -> UnicodeDecodingOutputStream<Unicode.UTF8> {

        UnicodeDecodingOutputStream(dest: self)
    }

    func utf16String() -> UnicodeDecodingOutputStream<Unicode.UTF16> {

        UnicodeDecodingOutputStream(dest: self)
    }

    func utf32String() -> UnicodeDecodingOutputStream<Unicode.UTF32> {

        UnicodeDecodingOutputStream(dest: self)
    }
}

class UnicodeDecodingOutputStream<Codec: UnicodeCodec> : OutputStream {

    typealias Datum = Codec.CodeUnit

    convenience init<Source: OutputStream>(
        dest: Source
    ) where Codec == Unicode.UTF8, Source.Datum == Character {

        self.init(
            dest: dest,
            codec: Unicode.UTF8()
        )
    }

    convenience init<Source: OutputStream>(
        dest: Source
    ) where Codec == Unicode.UTF16, Source.Datum == Character {

        self.init(
            dest: dest,
            codec: Unicode.UTF16()
        )
    }

    convenience init<Source: OutputStream>(
        dest: Source
    ) where Codec == Unicode.UTF32, Source.Datum == Character {

        self.init(
            dest: dest,
            codec: Unicode.UTF32()
        )
    }

    init<Source: OutputStream>(
        dest: Source,
        codec: Codec
    ) where Source.Datum == Character {

        self.dest = dest.erase()
        self.codec = codec
    }

    func write(_ datum: Codec.CodeUnit) async throws {

        buffer.append(datum)

        guard buffer.count == bufferSize else {
            return
        }

        let result = self.codec.decode(&buffer)

        switch result {

        case .scalarValue(let value):
            try await dest.write(Character(value))

        case .emptyInput:
            break

        case .error:
            throw UnicodeDecodeError()
        }
    }

    func flush() async throws {

    }

    private var bufferSize: Int { 4 / MemoryLayout<Codec.CodeUnit>.size }

    private let dest: AnyOutputStream<Character>
    private var codec: Codec

    private var buffer = Buffer<Codec.CodeUnit>()
}
