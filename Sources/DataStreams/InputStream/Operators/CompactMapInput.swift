//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

extension InputStream {

    public func compactMapIn<Result>(_ transform: @escaping (Datum) async throws -> Result?) -> AnyInputStream<Result> {

        self
            .map(transform)
            .compactIn()
    }
}