//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public typealias InputOutputStream = DataStreams.InputStream & DataStreams.OutputStream

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
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

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension InputStream where Self: OutputStream {

    public func erase() -> AnyInputOutputStream<Datum> {

        AnyInputOutputStream(erasing: self)
    }
}