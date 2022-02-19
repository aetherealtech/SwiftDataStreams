//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import CoreExtensions
import Observer
import EventStreams

@testable import DataStreams

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class SinkEventStreamTests: XCTestCase {

    func testSinkEventStream() async throws {

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

        let outputStream = [Event<Int>]().asStream()

        let subscription = eventStream.sink(to: outputStream)

        let values = Array(0..<10)

        Task {

            for value in values {

                try await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000))

                publish(value)
            }

            complete()
        }

        try await Task.sleep(nanoseconds: UInt64(1e9))

        XCTAssertEqual(outputStream.data.map { event in event.value }, values)

        withExtendedLifetime(subscription, {})
    }
}
