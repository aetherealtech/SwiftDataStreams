//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

public protocol InputStream : AnyObject, AsyncSequence, AsyncIteratorProtocol where Element == Datum {

    associatedtype Datum

    func hasMore() async throws -> Bool

    func read() async throws -> Datum

    func skip(count: Int) async throws -> Int
}

public struct EndOfStreamError : Error {

    public init() {

    }
}

extension InputStream {

    public func readInto(buffer: UnsafeMutableBufferPointer<Datum>) async throws -> Int {

        var index = 0

        while index < buffer.count {
            if !(try await hasMore()) {
                break
            }

            buffer[index] = try await read()
            index += 1
        }

        return index
    }

    public func read<Destination: RangeReplaceableCollection>(
        count: Int,
        destination: Destination = Destination()
    ) async throws -> Destination where Destination.Element == Datum {

        var result = destination

        var index = 0

        while index < count {
            if !(try await hasMore()) {
                break
            }

            result.append(try await read())
            index += 1
        }

        return result
    }

    public func readAll<Destination: RangeReplaceableCollection>(
        destination: Destination = Destination()
    ) async throws -> Destination where Destination.Element == Datum {

        var result = destination

        while try await hasMore() {
            result.append(try await read())
        }

        return result
    }

    public func readUntil<Destination: RangeReplaceableCollection>(
        destination: Destination = Destination(),
        stopCondition: (Datum) -> Bool
    ) async throws -> Destination where Destination.Element == Datum {

        var result = destination

        while try await hasMore() {
            let next = try await read()
            result.append(next)
            if stopCondition(next) {
                break
            }
        }

        return result
    }

    public func makeAsyncIterator() -> Self {

        self
    }

    public func next() async throws -> Datum? {

        guard !Task.isCancelled, try await hasMore() else {
            return nil

        }

        return try await read()
    }
}

public class AnyInputStream<Datum> : InputStream {

    public func hasMore() async throws -> Bool {

        try await hasMoreImp()
    }

    public func read() async throws -> Datum {

        try await readImp()
    }

    public func skip(count: Int) async throws -> Int {

        try await skipImp(count)
    }

    init<Source: InputStream>(erasing: Source) where Source.Datum == Datum {

        self.hasMoreImp = erasing.hasMore
        self.readImp = erasing.read
        self.skipImp = erasing.skip
    }

    private let hasMoreImp: () async throws -> Bool
    private let readImp: () async throws -> Datum
    private let skipImp: (Int) async throws -> Int
}

extension InputStream {

    public func erase() -> AnyInputStream<Datum> {

        AnyInputStream(erasing: self)
    }
}