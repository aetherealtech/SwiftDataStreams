//
//  DataStreamTests.swift
//  DataStreamTests
//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

class CompactMapInputTests: XCTestCase {

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
        
        let sourceStream = source.asStream()
            .compactMapIn(transform)

        try await testInputStream(
            stream: sourceStream,
            expectedElements: source.compactMap(transform)
        )
    }
}