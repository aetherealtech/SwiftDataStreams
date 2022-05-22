//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

class StringStreamTests: XCTestCase {

    private let testString = "BláhBlãh"

    private let testUTF8Bytes: [UInt8] = [
        66,
        108,
        195,
        161,
        104,
        66,
        108,
        195,
        163,
        104
    ]

    private let testUTF16Bytes: [UInt16] = [
        66,
        108,
        225,
        104,
        66,
        108,
        227,
        104
    ]

    func testStringStreamUTF8Encode() async throws {

        let encoded = testString
            .asStream()
            .utf8Characters()

        let bytes: [UInt8] = try await encoded
            .readAll()

        XCTAssertEqual(bytes, testUTF8Bytes)
    }

    func testStringStreamUTF8Decode() async throws {

        let decoded = testUTF8Bytes
            .asStream()
            .utf8String()

        let result: String = try await decoded
            .readAll()

        XCTAssertEqual(result, testString)
    }

    func testStringStreamUTF16Encode() async throws {

        let encoded = testString
            .asStream()
            .utf16Characters()

        let bytes: [UInt16] = try await encoded
            .readAll()

        XCTAssertEqual(bytes, testUTF16Bytes)
    }

    func testStringStreamUTF16Decode() async throws {

        let decoded = testUTF16Bytes
            .asStream()
            .utf16String()

        let result: String = try await decoded
            .readAll()

        XCTAssertEqual(result, testString)
    }
}