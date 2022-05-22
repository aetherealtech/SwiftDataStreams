//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

class FlattenInputTests: XCTestCase {

    func testFlatten() async throws {

        let source: [[Int]] = [
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
        ].map { value in

            [1, 2, 3, 4, 5]
            .map { innerValue in innerValue * value }
        }

        let sourceStreams = source
            .map { innerSource in innerSource.asStream() }

        let sourceStream = sourceStreams.asStream()
            .flatten()

        try await testInputStream(
            stream: sourceStream,
            expectedElements: source.flatten()
        )
    }
}