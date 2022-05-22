//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

import CoreExtensions

extension InputStream where Datum: OptionalProtocol {

    public func compactIn() -> AnyInputStream<Datum.Wrapped> {

        self
            .filterIn { datum in datum != nil }
            .map { datum in datum.unsafelyUnwrapped }
    }
}