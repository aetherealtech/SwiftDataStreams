//
//  DataStreamTests.swift
//  DataStreamTests
//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

class CompactOutputTests: XCTestCase {

    func testCompact() async throws {

        let source: [Int?] = [
            1,
            2,
            nil,
            4,
            nil,
            nil,
            7,
            nil,
            nil,
            10
        ]

        let destination = [Int]().asStream()

        let stream = destination
            .compactOut()

        try await stream.write(source: source)

        XCTAssertEqual(
            destination.data,
            source.compact()
        )
    }
}