//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import Observer
import EventStreams

@testable import DataStreams

class BufferedEventStreamTests: XCTestCase {

    func testBufferedEventStream() async throws {

        let channel = SimpleChannel<Int>()

        let eventStream = channel.asStream()

        let bufferedEventStream = eventStream.buffered()

        let values = Array(0..<10)

        try await Task {

            for value in values {

                try await Task.sleep(nanoseconds: UInt64.random(in: 1000..<1000000))

                channel.publish(value)
            }
        }.finish()

        let events: [Event<Int>] = try await bufferedEventStream.read(count: values.count)

        let result = events.map { event in event.value }

        XCTAssertEqual(result, values)
    }
}
