//
//  Created by Daniel Coleman on 11/18/21.
//

import XCTest
import CoreExtensions

@testable import DataStreams

class SequenceInputStreamTests: XCTestCase {

    func testGeneratorAsStream() async throws {

        let generator: (Int) -> Int = { n in n * n }

        let source = Generators.sequence(generator)
        let sourceCopy = Generators.sequence(generator)

        let sourceStream = source.asStream()

        try await testInputStream(
            stream: sourceStream,
            expectedElements: sourceCopy,
            limit: 100
        )
    }
}
