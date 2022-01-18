//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension InputStream {

    public func flatMap<ResultStream: InputStream>(_ transform: @escaping ((Datum) async throws -> ResultStream)) -> AnyInputStream<ResultStream.Datum> {

        self
            .map(transform)
            .flatten()
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Sequence {

    public func flatMap<ResultStream: InputStream>(_ transform: @escaping ((Element) async throws -> ResultStream)) -> AnyInputStream<ResultStream.Datum> {

        self.asStream()
            .map(transform)
            .flatten()
    }
}