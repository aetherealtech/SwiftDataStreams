//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import Observer
import EventStreams

@testable import DataStreams

class BufferedEventStreamTests: XCTestCase {

    func testBufferedEventStream() async throws {

        var capturePublish: ((Int) -> Void)!
        var captureComplete: (() -> Void)!

        let eventStream = EventStream<Int>(
            registerValues: { streamPublish, streamComplete in

                capturePublish = streamPublish
                captureComplete = streamComplete
            },
            unregister: { _ in

            }
        )

        let publish = capturePublish!
        let complete = captureComplete!

        let bufferedEventStream = eventStream.buffered()

        let values = Array(0..<10)

        Task {

            for value in values {

                try await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000))

                publish(value)
            }

            complete()
        }

        let events: [Event<Int>] = try await bufferedEventStream.readAll()

        let result = events.map { event in event.value }

        XCTAssertEqual(result, values)
    }
}
