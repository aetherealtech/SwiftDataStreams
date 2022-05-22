//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

class FilterOutputTests: XCTestCase {

    func testFilter() async throws {

        let source = Array(0..<10)

        let destination = [Int]().asInputOutputStream()

        let filter: (Int) -> Bool = { value in value % 3 == 0 }

        let stream = destination
            .filterOut(filter)

        try await stream.write(source: source)

        XCTAssertEqual(
            destination.data,
            source.filter(filter)
        )
    }
}
