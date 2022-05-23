//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import CoreExtensions

@testable import DataStreams

class PipelinesTests: XCTestCase {

    func testConnect() async throws {

        let source = (0..<Int(1e6)).map { _ in

            Int.random(in: 100..<10000)
        }

        let sourceStream = source.asStream()

        let destination = [Int]().asInputOutputStream()

        let pipeline = sourceStream.connect(to: destination)

        try await pipeline.finish()

        XCTAssertEqual(
            destination.data,
            source
        )
    }

    func testConnectLimit() async throws {

        let source = (0..<Int(1e6)).map { _ in

            Int.random(in: 100..<10000)
        }

        let limit = 158

        let sourceStream = source.asStream()

        let destination = [Int]().asInputOutputStream()

        let pipeline = sourceStream.connect(to: destination, limit: UInt64(limit))

        try await pipeline.finish()

        XCTAssertEqual(
            destination.data,
            Array(source[0..<limit])
        )
    }

    func testConnectError() async throws {

        let error = NSError(
            domain: "Test Error",
            code: 0,
            userInfo: nil
        )

        let source: AsyncGenerator<Int> = AsyncGenerators.sequence { index in

            if index == Int(5e4) {
                throw error
            }

            guard index < Int(1e6) else {
                return nil
            }

            return Int.random(in: 100..<10000)
        }

        let sourceStream = source.asStream()

        let destination = [Int]().asInputOutputStream()

        let pipeline = sourceStream.connect(to: destination)

        var receivedError: NSError?

        do {

            try await pipeline.finish()

        } catch(let error) {

            receivedError = error as NSError
        }

        XCTAssertEqual(
            error,
            receivedError
        )
    }
}
