//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

extension InputStream {

    public func tStream<Output>(output: Output) -> AnyInputStream<Datum> where Output: OutputStream, Output.Datum == Datum {

        TStream(
            input: self,
            output: output
        ).erase()
    }
}

class TStream<Input: InputStream, Output: OutputStream> : InputStream where Output.Datum == Input.Datum {

    typealias Datum = Input.Datum

    init(
        input: Input,
        output: Output
    ) {

        self.input = input
        self.output = output
    }

    func hasMore() async throws -> Bool {

        try await input.hasMore()
    }

    func read() async throws -> Input.Datum {

        let datum = try await input.read()
        try await output.write(datum)
        return datum
    }

    func skip(count: Int) async throws -> Int {

        var skipped = 0

        while skipped < count {
            _ = try await read()
            skipped += 1
        }

        return skipped
    }

    private let input: Input
    private let output: Output
}