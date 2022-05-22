//
//  DataStreamTests.swift
//  DataStreamTests
//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

class CompactMapOutputTests: XCTestCase {

    func testMap() async throws {

        let source: [Int] = [
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

        let transform: (Int) -> String? = { value in value % 3 == 0 ? "\(value)" : nil }

        let destination = [String]().asStream()

        let stream = destination
            .compactMapOut(transform)

        try await stream.write(source: source)

        XCTAssertEqual(
            destination.data,
            source.compactMap(transform)
        )
    }
}