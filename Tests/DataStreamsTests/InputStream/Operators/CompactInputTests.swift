//
//  DataStreamTests.swift
//  DataStreamTests
//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

class CompactInputTests: XCTestCase {

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

        let sourceStream = source.asStream()
            .compactIn()

        try await testInputStream(
            stream: sourceStream,
            expectedElements: source.compact()
        )
    }
}