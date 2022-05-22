//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

extension OutputStream {

    public func compactMapOut<Source>(_ transform: @escaping (Source) async throws -> Datum?) -> AnyOutputStream<Source> {

        self
            .compactOut()
            .map(transform)
    }
}