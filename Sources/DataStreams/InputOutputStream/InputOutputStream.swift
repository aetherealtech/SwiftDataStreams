//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

public typealias InputOutputStream = DataStreams.InputStream & DataStreams.OutputStream

public class AnyInputOutputStream<Datum> : InputOutputStream {

    public func hasMore() async throws -> Bool {

        try await inputStream.hasMore()
    }

    public func read() async throws -> Datum {

        try await inputStream.read()
    }

    public func skip(count: Int) async throws -> Int {

        try await inputStream.skip(count: count)
    }

    public func write(_ datum: Datum) async throws {

        try await outputStream.write(datum)
    }

    public func flush() async throws {

        try await outputStream.flush()
    }

    init<Source: InputOutputStream>(erasing: Source) where Source.Datum == Datum {

        self.inputStream = erasing.erase()
        self.outputStream = erasing.erase()
    }

    private let inputStream: AnyInputStream<Datum>
    private let outputStream: AnyOutputStream<Datum>
}

extension InputStream where Self: OutputStream {

    public func erase() -> AnyInputOutputStream<Datum> {

        AnyInputOutputStream(erasing: self)
    }
}