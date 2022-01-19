//
//  DataStreamTests.swift
//  DataStreamTests
//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest

@testable import DataStreams

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
func testInputStream<Stream: DataStreams.InputStream, Source: Collection>(
    stream: Stream,
    expectedElements: Source
) async throws where Stream.Datum: Equatable, Source.Element == Stream.Datum {

    try await testInputStream(
        stream: stream,
        expectedElements: expectedElements,
        equater: ==
    )
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
func testInputStream<Stream: DataStreams.InputStream, Source: Collection>(
    stream: Stream,
    expectedElements: Source,
    equater: (Source.Element, Source.Element) -> Bool
) async throws where Source.Element == Stream.Datum {

    var result = [Stream.Datum]()

    while try await stream.hasMore() {
        let next = try await stream.read()
        result.append(next)
    }

    XCTAssertTrue(
        result.elementsEqual(expectedElements, by: equater)
    )
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
func testInputStream<Stream: DataStreams.InputStream, Source: Sequence>(
    stream: Stream,
    expectedElements: Source,
    limit: Int
) async throws where Stream.Datum: Equatable, Source.Element == Stream.Datum {

    var count = 0
    for expectedNext in expectedElements {
        let next = try await stream.read()
        XCTAssertEqual(next, expectedNext)

        count += 1
        if count == limit {
            break
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
func testOutputStream<Stream: DataStreams.OutputStream, Source: Collection, Expected: Collection>(
    stream: Stream,
    source: Source,
    destination: CollectionInputStream<[Stream.Datum]>,
    expectedElements: Expected
) async throws where Stream.Datum: Equatable, Source.Element == Stream.Datum, Expected.Element == Stream.Datum {

    try await testOutputStream(
        stream: stream,
        source: source,
        destination: destination,
        expectedElements: expectedElements,
        equater: ==
    )
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
func testOutputStream<Stream: DataStreams.OutputStream, Source: Collection, Expected: Collection>(
    stream: Stream,
    source: Source,
    destination: CollectionInputStream<[Stream.Datum]>,
    expectedElements: Expected,
    equater: (Source.Element, Source.Element) -> Bool
) async throws where Source.Element == Stream.Datum, Expected.Element == Stream.Datum {

    for element in source {
        try await stream.write(element)
    }

    XCTAssertTrue(
        destination.data.elementsEqual(expectedElements, by: equater)
    )
}