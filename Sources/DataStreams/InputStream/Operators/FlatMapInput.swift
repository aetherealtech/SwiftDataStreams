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

    public func flatMap<ResultSequence: Sequence>(_ transform: @escaping (Datum) async throws -> ResultSequence) -> AnyInputStream<ResultSequence.Element> {

        self
            .flatMap { datum in try await transform(datum).asStream() }
    }
}

extension Sequence {

    public func flatMap<ResultStream: InputStream>(_ transform: @escaping (Element) async throws -> ResultStream) -> AnyInputStream<ResultStream.Datum> {

        self.asStream()
            .map(transform)
            .flatten()
    }
}