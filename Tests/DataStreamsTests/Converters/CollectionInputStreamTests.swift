//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class CollectionInputStreamTests: XCTestCase {

    func testArrayAsStream() async throws {

        let source = [
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10
        ]

        let sourceStream = source.asStream()

        try await testStream(
            stream: sourceStream,
            expectedElements: source
        )
    }

    func testMapAsStream() async throws {

        let source = [
            1: "1",
            2: "2",
            3: "3",
            4: "4",
            5: "5",
            6: "6",
            7: "7",
            8: "8",
            9: "9",
            10: "10"
        ]

        let sourceStream = source.asStream()

        try await testStream(
            stream: sourceStream,
            expectedElements: source,
            equater: { (kvp1, kvp2) in kvp1.key == kvp2.key && kvp1.value == kvp2.value }
        )
    }

    func testStringAsStream() async throws {

        let source = "BlahBlah"

        let sourceStream = source.asStream()

        try await testStream(
            stream: sourceStream,
            expectedElements: source
        )
    }
}
