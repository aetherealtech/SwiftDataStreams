//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

extension InputStream {

    public func flatMap<ResultStream: InputStream>(_ transform: @escaping (Datum) async throws -> ResultStream) -> AnyInputStream<ResultStream.Datum> {

        self
            .map(transform)
            .flatten()
    }
}

extension Sequence {

    public func flatMap<ResultStream: InputStream>(_ transform: @escaping (Element) async throws -> ResultStream) -> AnyInputStream<ResultStream.Datum> {

        self.asStream()
            .map(transform)
            .flatten()
    }
}