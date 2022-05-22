//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

import CoreExtensions

extension OutputStream {

    public func compactOut() -> AnyOutputStream<Datum?> {

        self
            .map { datum in datum.unsafelyUnwrapped }
            .filterOut { datum in datum != nil }
    }
}