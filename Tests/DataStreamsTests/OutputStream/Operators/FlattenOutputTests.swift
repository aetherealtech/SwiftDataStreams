//
//  DataStreamTests.swift
//  DataStreamTests
//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

class FlattenOutputTests: XCTestCase {

    func testFlatten() async throws {

        let source = Array(0..<10)
            .map { outerValue in

                Array(0..<10).map { innerValue in

                    "\(outerValue):\(innerValue)"
                }
            }

        let expectedValues = source.flatten()

        let destination = [String]().asStream()

        let stream: AnyOutputStream<AnyInputStream<String>> = destination
            .flatten()

        for innerStream in source {
            try await stream.write(innerStream.asStream())
        }

        XCTAssertEqual(
            destination.data,
            expectedValues
        )
    }
}