//
//  DataStreamTests.swift
//  DataStreamTests
//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class TStreamTests: XCTestCase {

    func testTStream() async throws {

        let source = Array(0..<10)

        let destination = [Int]().asStream()

        let stream = source
                .asStream()
                .tStream(output: destination)

        var valuesRead = [Int]()

        for try await value in stream {

            valuesRead.append(value)

            XCTAssertEqual(
                destination.data,
                valuesRead
            )
        }

        XCTAssertEqual(valuesRead, source)
    }
}