//
// Created by Daniel Coleman on 11/19/21.
//

import Foundation

public enum StreamPosition : Int {
    case beginning = 0
    case current = 1
    case end = 2
}

public protocol SeekableStream {

    var position: Int { get }

    func seek(position: Int) async throws -> Bool
}

public typealias SeekableInputStream = InputStream & SeekableStream

public typealias SeekableOutputStream = OutputStream & SeekableStream

public typealias SeekableInputOutputStream = SeekableInputStream & SeekableOutputStream

public class AnySeekableInputStream<Datum> : AnyInputStream<Datum>, SeekableStream {

    public var position: Int { seekableStream.position }

    public func seek(position: Int) async throws -> Bool {

        try await seekableStream.seek(position: position)
    }

    init<Source: SeekableInputStream>(erasingSeekable erasing: Source) where Source.Datum == Datum {

        self.seekableStream = erasing
        super.init(erasing: erasing)
    }

    private let seekableStream: SeekableStream
}

public class AnySeekableOutputStream<Datum> : AnyOutputStream<Datum>, SeekableStream {

    public var position: Int { seekableStream.position }

    public func seek(position: Int) async throws -> Bool {

        try await seekableStream.seek(position: position)
    }

    init<Source: SeekableOutputStream>(erasingSeekable erasing: Source) where Source.Datum == Datum {

        self.seekableStream = erasing
        super.init(erasing: erasing)
    }

    private let seekableStream: SeekableStream
}

extension InputStream where Self: SeekableStream {

    public func erase() -> AnySeekableInputStream<Datum> {

        AnySeekableInputStream(erasingSeekable: self)
    }
}

extension OutputStream where Self: SeekableStream {

    public func erase() -> AnySeekableOutputStream<Datum> {

        AnySeekableOutputStream(erasingSeekable: self)
    }
}

public class AnySeekableInputOutputStream<Datum> : SeekableInputOutputStream {

    public func hasMore() async throws -> Bool {
        try await inputStream.hasMore()
    }

    public func read() async throws -> Datum {
        try await inputStream.read()
    }

    public func write(_ datum: Datum) async throws {
        try await outputStream.write(datum)
    }

    public func flush() async throws {
        try await outputStream.flush()
    }

    public var position: Int { seekableStream.position }

    public func seek(position: Int) async throws -> Bool {

        try await seekableStream.seek(position: position)
    }

    init<Source: SeekableInputOutputStream>(erasingSeekable erasing: Source) where Source.Datum == Datum {

        self.inputStream = erasing.erase()
        self.outputStream = erasing.erase()
        self.seekableStream = erasing
    }

    private let inputStream: AnyInputStream<Datum>
    private let outputStream: AnyOutputStream<Datum>
    private let seekableStream: SeekableStream
}

extension OutputStream where Self: InputStream & SeekableStream {

    public func erase() -> AnySeekableInputOutputStream<Datum> {

        AnySeekableInputOutputStream(erasingSeekable: self)
    }
}

extension SeekableStream {

    public func seek(position: StreamPosition) async throws -> Bool {

        try await seek(position: position, offset: 0)
    }

    public func seek(position: StreamPosition, offset: Int) async throws -> Bool {

        let baseOffset: [StreamPosition: () async throws -> Int] = [
            .beginning: { 0 },
            .current: { self.position },
            .end: { try await self.length() }
        ]

        return try await seek(position: try await baseOffset[position]!() + offset)
    }

    public func skip(count: Int) async throws -> Int {

        let oldPosition = position
        let targetPosition = min(position + count, try await length())
        let offset = targetPosition - oldPosition
        _ = try await seek(position: .current, offset: offset)
        return offset
    }

    public func length() async throws -> Int {

        let current = position
        _ = try await seek(position: .end)
        let length = position
        _ = try await seek(position: .beginning, offset: current)
        return length
    }
}