//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation

extension OutputStream {

    public func flatMap<Source, OuterSequence: Sequence>(
        _ transform: @escaping (Source) async throws -> OuterSequence
    ) -> AnyOutputStream<Source> where OuterSequence.Element == Datum {

        self
            .flatten()
            .map(transform)
    }

    public func flatMap<Source, OuterSequence: AsyncSequence>(
        _ transform: @escaping (Source) async throws -> OuterSequence
    ) -> AnyOutputStream<Source> where OuterSequence.Element == Datum {

        self
            .flatten()
            .map(transform)
    }
}
