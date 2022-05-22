//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

class MapOutputTests: XCTestCase {

    func testMap() async throws {

        let source = Array(0..<10)

        let transform: (Int) -> String = { value in "\(value)" }

        let destination = [String]().asStream()

        let stream = destination
            .map(transform)

        try await stream.write(source: source)

        XCTAssertEqual(
            destination.data,
            source.map(transform)
        )
    }
}