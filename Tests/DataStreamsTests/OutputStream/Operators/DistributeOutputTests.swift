//
//  DataStreamTests.swift
//  DataStreamTests
//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class DistributeOutputTests: XCTestCase {

    func testMap() async throws {

        let source = Array(0..<10)

        let destinations = (0..<5).map { _ in [Int]().asStream() }

        let stream = destinations
            .distributed()

        try await stream.write(source: source)

        for destination in destinations {

            XCTAssertEqual(
                destination.data,
                source
            )
        }
    }
}