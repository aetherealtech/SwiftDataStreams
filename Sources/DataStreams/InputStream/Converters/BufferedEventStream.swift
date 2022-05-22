//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation
import CoreExtensions
import EventStreams
import Observer

extension EventStream {

    public func buffered() -> AnyInputStream<Event<Value>> {

        BufferedEventStream<Value>(source: self)
            .erase()
    }
}

class BufferedEventStream<Value> : InputStream {

    typealias Datum = Event<Value>

    init(source: EventStream<Value>) {

        sourceSubscription = source.subscribe(
            onEvent: onNext
        )
    }

    public func hasMore() async throws -> Bool {

        true
    }

    public func read() async throws -> Datum {

        if let buffered = buffer.next() {
            return buffered
        }

        return await waitForNext()
    }

    public func skip(count: Int) async throws -> Int {

        var remaining = count

        while remaining > 0 {

            if buffer.next() == nil {
                _ = await waitForNext()
            }

            remaining -= 1
        }

        return count
    }

    private func waitForNext() async -> Event<Value> {

        await waiter.wait()

        return buffer.next()!
    }

    private func onNext(_ event: Event<Value>) {

        buffer.append(event)
        waiter.signal()
    }

    private let buffer = Buffer<Event<Value>>()

    private let waiter = SignalEvent()

    private var sourceSubscription: Subscription!
}