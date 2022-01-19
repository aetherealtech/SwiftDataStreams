//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension OutputStream {

    public func compactMapOut<Source>(_ transform: @escaping ((Source) async throws -> Datum?)) -> AnyOutputStream<Source> {

        self
            .compactOut()
            .map(transform)
    }
}