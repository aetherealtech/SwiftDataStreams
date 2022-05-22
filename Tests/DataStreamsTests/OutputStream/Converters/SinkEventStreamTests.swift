//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import CoreExtensions
import Observer
import EventStreams

@testable import DataStreams

class SinkEventStreamTests: XCTestCase {

    func testSinkEventStream() async throws {

        let channel = SimpleChannel<Int>()

        let eventStream = channel.asStream()

        let outputStream = [Event<Int>]().asStream()

        let subscription = eventStream.sink(to: outputStream)

        let values = Array(0..<10)

        try await Task {

            for value in values {

                try await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000))

                channel.publish(value)
            }
        }.finish()

        XCTAssertEqual(outputStream.data.map { event in event.value }, values)

        withExtendedLifetime(subscription, {})
    }
}
