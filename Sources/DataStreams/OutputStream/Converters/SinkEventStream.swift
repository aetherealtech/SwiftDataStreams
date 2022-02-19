//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation
import EventStreams
import Observer

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension EventStream {

    public func sink<Destination: OutputStream>(to destination: Destination) -> Subscription where Destination.Datum == Event<Value> {

        subscribe(onEvent: { event in

            Task {

                try await destination.write(event)
            }
        })
    }
}