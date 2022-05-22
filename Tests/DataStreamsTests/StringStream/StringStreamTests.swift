//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
@testable import DataStreams

class StringStreamTests: XCTestCase {

    private let testString = "Bláh😊Blᴕ̈h业Yo丣Dawg"

    private let testUTF8CodeUnits: [UInt8] = [
        66,
        108,
        195,
        161,
        104,
        240,
        159,
        152,
        138,
        66,
        108,
        225,
        180,
        149,
        204,
        136,
        104,
        228,
        184,
        154,
        89,
        111,
        228,
        184,
        163,
        68,
        97,
        119,
        103
    ]

    private let testUTF16CodeUnits: [UInt16] = [
        66,
        108,
        225,
        104,
        55357,
        56842,
        66,
        108,
        7445,
        776,
        104,
        19994,
        89,
        111,
        20003,
        68,
        97,
        119,
        103
    ]
    
    private let testUTF32CodeUnits: [UInt32] = [
        66,
        108,
        225,
        104,
        128522,
        66,
        108,
        7445,
        776,
        104,
        19994,
        89,
        111,
        20003,
        68,
        97,
        119,
        103
    ]

    func testStringStreamUTF8Encode() async throws {

        let encoded = testString
            .asStream()
            .utf8CodePoints()

        let codeUnits: [UInt8] = try await encoded
            .readAll()

        XCTAssertEqual(codeUnits, testUTF8CodeUnits)
    }

    func testStringStreamUTF8Decode() async throws {

        let decoded = testUTF8CodeUnits
            .asStream()
            .utf8String()

        let result: String = try await decoded
            .readAll()

        XCTAssertEqual(result, testString)
    }

    func testStringStreamUTF16Encode() async throws {

        let encoded = testString
            .asStream()
            .utf16CodePoints()

        let codeUnits: [UInt16] = try await encoded
            .readAll()

        XCTAssertEqual(codeUnits, testUTF16CodeUnits)
    }

    func testStringStreamUTF16Decode() async throws {

        let decoded = testUTF16CodeUnits
            .asStream()
            .utf16String()

        let result: String = try await decoded
            .readAll()

        XCTAssertEqual(result, testString)
    }
    
    func testStringStreamUTF32Encode() async throws {
        
        let encoded = testString
            .asStream()
            .utf32CodePoints()

        let codeUnits: [UInt32] = try await encoded
            .readAll()

        XCTAssertEqual(codeUnits, testUTF32CodeUnits)
    }

    func testStringStreamUTF32Decode() async throws {

        let decoded = testUTF32CodeUnits
            .asStream()
            .utf32String()

        let result: String = try await decoded
            .readAll()

        XCTAssertEqual(result, testString)
    }
}
