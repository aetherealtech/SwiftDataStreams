//
//  DataStreamTests.swift
//  DataStreamTests
//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import CoreExtensions

@testable import DataStreams

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class BufferedInputTests: XCTestCase {

    func testReadAll() async throws {

        let generator: (Int) -> Int = { n in n * n }

        let source = Generators.sequence(generator)
        let sourceCopy = Generators.sequence(generator)

        let sourceStream = source.asStream().buffered()

        try await testInputStream(
            stream: sourceStream,
            expectedElements: sourceCopy,
            limit: 100
        )
    }

    func testSeekableCollectionInput() async throws {

        let generator: (Int) -> Int = { n in n * n }

        let source = Array(Generators.sequence(generator).prefix(100))

        let sourceStream = Generators.sequence(generator)
            .asStream()
            .buffered()

        var range = 5..<15
        var sourceSlice = source[range]

        var succeeded = try await sourceStream.seek(position: .beginning, offset: range.lowerBound)
        XCTAssertTrue(succeeded)

        try await testInputStream(
            stream: sourceStream,
            expectedElements: sourceSlice,
            limit: range.count
        )

        range = 80..<95
        sourceSlice = source[range]
        
        succeeded = try await sourceStream.seek(position: .beginning, offset: range.lowerBound)
        XCTAssertTrue(succeeded)

        try await testInputStream(
            stream: sourceStream,
            expectedElements: sourceSlice,
            limit: range.count
        )
        
        range = 40..<50
        sourceSlice = source[range]
        
        succeeded = try await sourceStream.seek(position: .beginning, offset: range.lowerBound)
        XCTAssertTrue(succeeded)

        try await testInputStream(
            stream: sourceStream,
            expectedElements: sourceSlice,
            limit: range.count
        )
    }
}
