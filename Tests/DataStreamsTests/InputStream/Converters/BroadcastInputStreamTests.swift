//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import CoreExtensions
import Observer
import EventStreams

@testable import DataStreams

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class BroadcastInputStreamTests: XCTestCase {

    func testBroadcastInputStream() async throws {

        let values = (0..<10).map { _ in Int.random(in: 10..<100)}

        let signal = SignalEvent()

        let generator = AsyncGenerators.sequence { index -> Int? in

            await signal.wait()

            return index < values.count ? values[index] : nil
        }

        let inputStream = generator.asStream()
        let eventStream = inputStream.broadcast()

        var receivedValues = [Int]()

        let subscription = eventStream.subscribe { value in

            receivedValues.append(value)
        }

        signal.signal(reset: false)

        try await Task.sleep(nanoseconds: UInt64(1e9))

        XCTAssertEqual(values, receivedValues)

        withExtendedLifetime(subscription, {})
    }
}
