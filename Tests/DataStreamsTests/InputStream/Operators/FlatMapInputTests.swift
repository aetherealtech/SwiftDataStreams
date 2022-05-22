//
//  DataStreamTests.swift
//  DataStreamTests
//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

class FlatMapInputTests: XCTestCase {

    func testFlatMap() async throws {

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

        let transform: (Int) -> [Int] = { value in

            [1, 2, 3, 4, 5]
                .map { innerValue in innerValue * value }
        }

        let sourceStream = source.asStream()
            .flatMap { value in transform(value).asStream() }

        try await testInputStream(
            stream: sourceStream,
            expectedElements: source.flatMap(transform)
        )
    }
}