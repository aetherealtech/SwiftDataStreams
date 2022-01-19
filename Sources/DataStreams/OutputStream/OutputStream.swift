//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public protocol OutputStream : AnyObject {

    associatedtype Datum

    func write(_ datum: Datum) async throws

    func flush() async throws
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension OutputStream {

    public func writeFrom(buffer: UnsafeMutableBufferPointer<Datum>) async throws {

        var index = 0

        while index < buffer.count {

            try await write(buffer[index])
            index += 1
        }
    }

    public func write<Source: Sequence>(
        source: Source
    ) async throws where Source.Element == Datum {

        for datum in source {
            try await write(datum)
        }
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public class AnyOutputStream<Datum> : OutputStream {

    public func write(_ datum: Datum) async throws {
        
        try await writeImp(datum)
    }

    public func flush() async throws {

        try await flushImp()
    }

    init<Source: OutputStream>(erasing: Source) where Source.Datum == Datum {

        self.writeImp = erasing.write
        self.flushImp = erasing.flush
    }

    private let writeImp: (Datum) async throws -> Void
    private let flushImp: () async throws -> Void
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension OutputStream {

    public func erase() -> AnyOutputStream<Datum> {

        AnyOutputStream(erasing: self)
    }
}