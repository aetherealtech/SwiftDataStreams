//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Collection where Element: OutputStream {

    public func distributed() -> AnyOutputStream<Element.Datum> {

        DistributeOutputStream(
            destinations: self
        ).erase()
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class DistributeOutputStream<DestinationStreams: Collection> : OutputStream where DestinationStreams.Element: OutputStream {

    typealias Datum = DestinationStreams.Element.Datum

    init(
        destinations: DestinationStreams
    ) {

        self.destinations = destinations
    }

    func write(_ datum: Datum) async throws {

        for destination in destinations {
            try await destination.write(datum)
        }
    }

    func flush() async throws {

        for destination in destinations {
            try await destination.flush()
        }
    }

    private let destinations: DestinationStreams
}