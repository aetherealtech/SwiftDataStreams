//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

public protocol OutputStream : AnyObject {

    associatedtype Datum

    func write(_ datum: Datum) async throws

    func flush() async throws
}

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

    public func write<Source: AsyncSequence>(
        source: Source
    ) async throws where Source.Element == Datum {

        for try await datum in source {
            try await write(datum)
        }
    }
}

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

extension OutputStream {

    public func erase() -> AnyOutputStream<Datum> {

        AnyOutputStream(erasing: self)
    }
}