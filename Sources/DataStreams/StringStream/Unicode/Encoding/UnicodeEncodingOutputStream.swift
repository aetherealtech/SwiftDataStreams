//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation

extension OutputStream where Datum == Unicode.UTF8.CodeUnit {

    func utf8Characters() -> UnicodeEncodingOutputStream<Unicode.UTF8> {

        UnicodeEncodingOutputStream(dest: self)
    }
}

extension OutputStream where Datum == Unicode.UTF16.CodeUnit {

    func utf16Characters() -> UnicodeEncodingOutputStream<Unicode.UTF16> {

        UnicodeEncodingOutputStream(dest: self)
    }
}

extension OutputStream where Datum == Unicode.UTF32.CodeUnit {

    func utf32Characters() -> UnicodeEncodingOutputStream<Unicode.UTF32> {

        UnicodeEncodingOutputStream(dest: self)
    }
}

class UnicodeEncodingOutputStream<Codec: UnicodeCodec> : OutputStream {

    typealias Datum = Character

    init<Dest: OutputStream>(
        dest: Dest
    ) where Dest.Datum == Codec.CodeUnit {

        self.dest = dest.erase()
    }

    func write(_ datum: Character) async throws {

        let scalars = datum.unicodeScalars

        for scalar in scalars {
            guard let encoded = Codec.encode(scalar) else {
                throw UnicodeEncodeError()
            }

            try await dest.write(source: encoded)
        }
    }

    func flush() async throws {

    }

    private let dest: AnyOutputStream<Codec.CodeUnit>
}
