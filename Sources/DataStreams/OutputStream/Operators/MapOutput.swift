//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension OutputStream {

    public func map<Source>(_ transform: @escaping (Source) async throws -> Datum) -> AnyOutputStream<Source> {

        MappedOutputStream(
            destination: self,
            transform: transform
        ).erase()
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class MappedOutputStream<Source, Result> : OutputStream {

    typealias Datum = Source

    init<SourceStream: OutputStream>(
        destination: SourceStream,
        transform: @escaping (Source) async throws -> Result
    ) where SourceStream.Datum == Result {

        self.destination = destination.erase()
        self.transform = transform
    }

    func write(_ datum: Source) async throws {

        try await destination.write(transform(datum))
    }

    func flush() async throws {

        try await destination.flush()
    }

    private let destination: AnyOutputStream<Result>
    private let transform: (Source) async throws -> Result
}