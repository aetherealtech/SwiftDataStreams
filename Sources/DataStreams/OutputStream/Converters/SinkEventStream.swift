//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation
import EventStreams
import Observer

extension EventStream {

    public func sink<Destination: OutputStream>(to destination: Destination) -> Subscription where Destination.Datum == Event<Value> {

        subscribe(onEvent: { event in

            Task {

                try await destination.write(event)
            }
        })
    }
}