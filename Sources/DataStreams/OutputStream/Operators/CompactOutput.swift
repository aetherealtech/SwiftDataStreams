//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

import CoreExtensions

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension OutputStream {

    public func compactOut() -> AnyOutputStream<Datum?> {

        self
            .map { datum in datum.unsafelyUnwrapped }
            .filterOut { datum in datum != nil }
    }
}