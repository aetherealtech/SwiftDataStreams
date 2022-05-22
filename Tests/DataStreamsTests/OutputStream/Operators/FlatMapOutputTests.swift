//
//  DataStreamTests.swift
//  DataStreamTests
//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

class FlatMapOutputTests: XCTestCase {

    func testFlatMap() async throws {

        let source = Array(0..<10)

        let transform: (Int) -> [String] = { outerValue in

            Array(0..<10).map { innerValue in

                "\(outerValue):\(innerValue)"
            }
        }

        let expectedValues = source.flatMap(transform)

        let destination = [String]().asStream()

        let stream = destination
            .flatMap(transform)

        try await stream.write(source: source)

        XCTAssertEqual(
            destination.data,
            expectedValues
        )
    }
}