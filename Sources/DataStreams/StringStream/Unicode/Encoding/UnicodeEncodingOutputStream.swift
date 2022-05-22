//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation

extension OutputStream where Datum == Unicode.UTF8.CodeUnit {

    func utf8Characters() -> AnyOutputStream<UnicodeScalar> {

        self
            .flatMap(Unicode.UTF8.encode)
            .erase()
    }

    func utf8Characters() -> StringOutputStream {

        self
            .utf8Characters()
            .string()
    }
}

extension OutputStream where Datum == Unicode.UTF16.CodeUnit {

    func utf16Characters() -> AnyOutputStream<UnicodeScalar> {

        self
            .flatMap(Unicode.UTF16.encode)
            .erase()
    }

    func utf16Characters() -> StringOutputStream {

        self
            .utf16Characters()
            .string()
    }
}

extension OutputStream where Datum == Unicode.UTF32.CodeUnit {

    func utf32Characters() -> AnyOutputStream<UnicodeScalar> {

        self
            .flatMap(Unicode.UTF32.encode)
            .erase()
    }

    func utf32Characters() -> StringOutputStream {

        self
            .utf32Characters()
            .string()
    }
}

extension UnicodeCodec {

    static func encode(scalar: UnicodeScalar) throws -> EncodedScalar {

        guard let encoded = Self.encode(scalar) else {
            throw UnicodeEncodeError()
        }

        return encoded
    }
}
