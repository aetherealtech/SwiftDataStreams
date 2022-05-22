//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation
import EventStreams
import Observer

extension InputStream {

    public func broadcast() -> EventStream<Datum> {

        BroadcastInputStream(
            source: self
        )
    }
}

class BroadcastInputStream<Source: InputStream> : EventStream<Source.Datum> {

    typealias Value = Source.Datum

    init(
        source: Source
    ) {

        let eventChannel = SimpleChannel<Event<Value>>()

        super.init(channel: eventChannel)

        Task { [weak self] in

            do {

                for try await value in source {

                    guard self != nil else { break }

                    eventChannel.publish(value)
                }
            }
            catch {

            }
        }
    }
}
