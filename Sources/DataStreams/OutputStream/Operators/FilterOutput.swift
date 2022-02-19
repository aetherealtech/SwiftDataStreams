//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension OutputStream {

    public func filterOut(_ condition: @escaping (Datum) async throws -> Bool) -> AnyOutputStream<Datum> {

        FilteredOutputStream(
            destination: self,
            condition: condition
        ).erase()
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class FilteredOutputStream<Datum> : OutputStream {

    init<SourceStream: OutputStream>(
        destination: SourceStream,
        condition: @escaping (Datum) async throws -> Bool
    ) where SourceStream.Datum == Datum {

        self.destination = destination.erase()
        self.condition = condition
    }

    func write(_ datum: Datum) async throws {

        if(try await condition(datum)) {
            try await destination.write(datum)
        }
    }

    func flush() async throws {

        try await destination.flush()
    }

    private let destination: AnyOutputStream<Datum>
    private let condition: (Datum) async throws -> Bool
}