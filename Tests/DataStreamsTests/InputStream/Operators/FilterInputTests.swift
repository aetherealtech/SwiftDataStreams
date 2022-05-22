//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

class FilterInputTests: XCTestCase {

    func testFilter() async throws {

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

        let filter: (Int) -> Bool = { value in value % 3 == 0 }

        let sourceStream = source.asStream()
            .filterIn(filter)

        try await testInputStream(
            stream: sourceStream,
            expectedElements: source.filter(filter)
        )
    }
}