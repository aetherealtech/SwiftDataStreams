//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

extension InputStream {

    public func map<Result>(_ transform: @escaping (Datum) async throws -> Result) -> AnyInputStream<Result> {

        MappedInputStream(
            source: self,
            transform: transform
        ).erase()
    }
}

class MappedInputStream<Source, Result> : InputStream {

    typealias Datum = Result

    init<SourceStream: InputStream>(
        source: SourceStream,
        transform: @escaping (Source) async throws -> Result
    ) where SourceStream.Datum == Source {

        self.source = source.erase()
        self.transform = transform
    }

    func hasMore() async throws -> Bool { try await source.hasMore() }

    func read() async throws -> Datum {

        try await transform(try await source.read())
    }

    func skip(count: Int) async throws -> Int {

        try await source.skip(count: count)
    }

    private let source: AnyInputStream<Source>
    private let transform: (Source) async throws -> Result
}