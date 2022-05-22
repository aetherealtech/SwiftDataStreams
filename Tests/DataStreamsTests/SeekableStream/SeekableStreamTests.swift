//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

class SeekableStreamTests: XCTestCase {

    func testSeekableCollectionInput() async throws {

        let source = [
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

        let sourceSlice = source[5..<10]

        let sourceStream = source.asStream()
            .erase()

        var succeeded = try await sourceStream.seek(position: .beginning)
        XCTAssertTrue(succeeded)

        try await testInputStream(
            stream: sourceStream,
            expectedElements: source
        )

        succeeded = try await sourceStream.seek(position: .beginning, offset: 5)
        XCTAssertTrue(succeeded)

        try await testInputStream(
            stream: sourceStream,
            expectedElements: sourceSlice
        )
    }

    func testSeekableCollectionOutput() async throws {

        let source = [
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

        let sourceStream = source.asStream()
            .erase()

        var succeeded = try await sourceStream.seek(position: .beginning)
        XCTAssertTrue(succeeded)

        var expected = source

        for i in 0..<3 {
            let value = 15
            try await sourceStream.write(value)
            expected[i] = value
        }

        try await testInputStream(
            stream: sourceStream,
            expectedElements: expected[3..<10]
        )

        succeeded = try await sourceStream.seek(position: .beginning)
        XCTAssertTrue(succeeded)

        try await testInputStream(
            stream: sourceStream,
            expectedElements: expected
        )

        succeeded = try await sourceStream.seek(position: .beginning, offset: 7)
        XCTAssertTrue(succeeded)

        for i in 7..<10 {
            let value = 18
            try await sourceStream.write(value)
            expected[i] = value
        }

        try await testInputStream(
            stream: sourceStream,
            expectedElements: []
        )

        succeeded = try await sourceStream.seek(position: .beginning)
        XCTAssertTrue(succeeded)

        try await testInputStream(
            stream: sourceStream,
            expectedElements: expected
        )
    }
}
