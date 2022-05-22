//
// Created by Daniel Coleman on 11/19/21.
//

import Foundation

typealias InputStringStream = AnyInputStream<Character>
typealias OutputStringStream = AnyOutputStream<Character>

extension InputStream where Datum == Character {

    func unicodeScalars() -> AnyInputStream<UnicodeScalar> {

        self
            .flatMap { character in character.unicodeScalars }
    }
}

extension OutputStream where Datum == UnicodeScalar {

    func string() -> AnyOutputStream<Character> {

        self
            .flatMap { character in character.unicodeScalars }
    }
}