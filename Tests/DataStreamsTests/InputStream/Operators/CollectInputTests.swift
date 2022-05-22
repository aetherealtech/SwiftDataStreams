//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

class CollectInputTests: XCTestCase {

    func testCollect() async throws {

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

        let expectedResult = [
            [source[0], source[1], source[2], source[3]],
            [source[4], source[5], source[6], source[7]],
            [source[8], source[9], 0, 0]
        ]

        let sourceStream = source.asStream()
            .collect(count: 4, padding: 0)

        try await testInputStream(
            stream: sourceStream,
            expectedElements: expectedResult
        )
    }

    func testCollectNoPadding() async throws {

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

        let expectedResult = [
            [source[0], source[1], source[2], source[3]],
            [source[4], source[5], source[6], source[7]]
        ]

        let sourceStream = source.asStream()
            .collect(count: 4)

        try await testInputStream(
            stream: sourceStream,
            expectedElements: expectedResult
        )
    }

    func testCollectOverlapping() async throws {

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

        let expectedResult = [
            [source[0], source[1], source[2], source[3]],
            [source[2], source[3], source[4], source[5]],
            [source[4], source[5], source[6], source[7]],
            [source[6], source[7], source[8], source[9]]
        ]

        let sourceStream = source.asStream()
            .collect(count: 4, stride: 2)

        try await testInputStream(
            stream: sourceStream,
            expectedElements: expectedResult
        )
    }
}
