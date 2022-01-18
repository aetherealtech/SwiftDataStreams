//
//  DataStreamTests.swift
//  DataStreamTests
//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
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
            .compactMap(transform)

        try await testStream(
            stream: sourceStream,
            expectedElements: source.compactMap(transform)
        )
    }
}