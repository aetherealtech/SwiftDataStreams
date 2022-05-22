//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation

extension OutputStream where Datum == Unicode.UTF8.CodeUnit {

    func unicodeScalars() -> AnyOutputStream<UnicodeScalar> {

        self
            .flatMap(Unicode.UTF8.encode)
            .erase()
    }

    func unicodeString() -> StringOutputStream {

        self
            .unicodeScalars()
            .string()
    }
}

extension OutputStream where Datum == Unicode.UTF16.CodeUnit {

    func unicodeScalars() -> AnyOutputStream<UnicodeScalar> {

        self
            .flatMap(Unicode.UTF16.encode)
            .erase()
    }

    func unicodeString() -> StringOutputStream {

        self
            .unicodeScalars()
            .string()
    }
}

extension OutputStream where Datum == Unicode.UTF32.CodeUnit {

    func unicodeScalars() -> AnyOutputStream<UnicodeScalar> {

        self
            .flatMap(Unicode.UTF32.encode)
            .erase()
    }

    func unicodeString() -> StringOutputStream {

        self
            .unicodeScalars()
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
