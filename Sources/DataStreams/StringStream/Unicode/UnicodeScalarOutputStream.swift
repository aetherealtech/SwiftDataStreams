//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation

extension OutputStream where Datum == Character {

    func unicodeScalars() -> AnyOutputStream<UnicodeScalar> {

        UnicodeScalarOutputStream(dest: self)
            .erase()
    }
}

class UnicodeScalarOutputStream : OutputStream {

    typealias Datum = UnicodeScalar

    init<Source: OutputStream>(
        dest: Source
    ) where Source.Datum == Character {

        self.dest = dest.erase()
    }

    func write(_ datum: UnicodeScalar) async throws {

        buffer.append(datum)

        let characters = String(String.UnicodeScalarView(buffer))

        if characters.count >= 2 {
            try await dest.write(source: characters)
            buffer.removeFirst(buffer.count - 1)
        }
    }

    func flush() async throws {

        try await dest.write(source: String(String.UnicodeScalarView(buffer)))

        buffer.removeAll()
    }

    private let dest: AnyOutputStream<Character>

    private var buffer = [UnicodeScalar]()
}
