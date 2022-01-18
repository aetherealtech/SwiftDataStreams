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

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension OutputStream {

    public func map<Source>(_ transform: @escaping ((Source) async throws -> Datum)) -> AnyOutputStream<Source> {

        MappedOutputStream(
            source: self,
            transform: transform
        ).erase()
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class MappedOutputStream<Source, Result> : OutputStream {

    typealias Datum = Source

    init<SourceStream: OutputStream>(
        source: SourceStream,
        transform: @escaping ((Source) async throws -> Result)
    ) where SourceStream.Datum == Result {

        self.source = source.erase()
        self.transform = transform
    }

    func write(_ datum: Datum) async throws {

        try await source.write(transform(datum))
    }

    func flush() async throws {

        try await source.flush()
    }

    private let source: AnyOutputStream<Result>
    private let transform: (Source) async throws -> Result
}

//@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
//extension OutputStream {
//
//    public func flatMap<ResultStream: OutputStream>(_ transform: @escaping ((Datum) async throws -> ResultStream)) -> AnyOutputStream<ResultStream.Datum> {
//
//        FlatMappedOutputStream(
//            source: self,
//            transform: transform
//        ).erase()
//    }
//}
//
//@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
//class FlatMappedOutputStream<Source, Result> : OutputStream {
//
//    typealias Datum = Result
//
//    init<SourceStream: OutputStream, ResultStream: OutputStream>(
//        source: SourceStream,
//        transform: @escaping ((Source) async throws -> ResultStream)
//    ) where SourceStream.Datum == Source, ResultStream.Datum == Result {
//
//        self.outerSource = source.erase()
//        self.transform = { source in try await transform(source).erase() }
//    }
//
//    func hasMore() async throws -> Bool {
//
//        if let innerSource = self.innerSource, try await innerSource.hasMore() {
//            return true
//        }
//
//        return try await outerSource.hasMore()
//    }
//
//    func read() async throws -> Datum {
//
//        if let innerSource = self.innerSource, try await innerSource.hasMore() {
//            return try await innerSource.read()
//        }
//
//        innerSource = try await transform(try await outerSource.read())
//        return try await read()
//    }
//
//    func skip(count: Int) async throws -> Int {
//
//        guard count > 0 else { return 0 }
//
//        var remaining = count
//
//        if let innerSource = self.innerSource, try await innerSource.hasMore() {
//            remaining -= try await innerSource.skip(count: remaining)
//        }
//
//        innerSource = try await transform(try await outerSource.read())
//        return try await skip(count: remaining)
//    }
//
//    private let outerSource: AnyOutputStream<Source>
//    private var innerSource: AnyOutputStream<Result>?
//
//    private let transform: (Source) async throws -> AnyOutputStream<Result>
//}
//
//@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
//extension OutputStream {
//
//    public func filter(_ condition: @escaping ((Datum) async throws -> Bool)) -> AnyOutputStream<Datum> {
//
//        FilteredOutputStream(
//            source: self,
//            condition: condition
//        ).erase()
//    }
//}
//
//@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
//class FilteredOutputStream<Datum> : OutputStream {
//
//    init<SourceStream: OutputStream>(
//        source: SourceStream,
//        condition: @escaping ((Datum) async throws -> Bool)
//    ) where SourceStream.Datum == Datum {
//
//        self.source = source.erase()
//        self.condition = condition
//    }
//
//    func hasMore() async throws -> Bool {
//
//        if next != nil {
//            return true
//        }
//        if try await readAhead() != nil {
//            return true
//        }
//        return false
//    }
//
//    func read() async throws -> Datum {
//
//        if let next = self.next {
//            self.next = nil
//            return next
//        }
//        guard let next = try await readAhead() else {
//            throw EndOfStreamError()
//        }
//        return next
//    }
//
//    func skip(count: Int) async throws -> Int {
//
//        for skipped in 0..<count {
//            guard try await readAhead() != nil else {
//                return skipped
//            }
//        }
//
//        return count
//    }
//
//    private func readAhead() async throws -> Datum? {
//
//        while true {
//            if !(try await source.hasMore()) {
//                return nil
//            }
//
//            let peek = try await source.read()
//            if try await condition(peek) {
//                next = peek
//                return peek
//            }
//        }
//    }
//
//    private let source: AnyOutputStream<Datum>
//    private var next: Datum?
//
//    private let condition: (Datum) async throws -> Bool
//}
//
//@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
//extension OutputStream {
//
//    public func collect(
//        count: Int,
//        padding: @escaping @autoclosure () -> Datum? = nil
//    ) -> AnyOutputStream<[Datum]> {
//
//        collect(
//            count: count,
//            stride: count,
//            padding: padding()
//        )
//    }
//
//    public func collect(
//        count: Int,
//        stride: Int,
//        padding: @escaping @autoclosure () -> Datum? = nil
//    ) -> AnyOutputStream<[Datum]> {
//
//        CollectedOutputStream(
//            source: self,
//            count: count,
//            stride: stride,
//            padding: padding()
//        ).erase()
//    }
//}
//
//@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
//class CollectedOutputStream<SourceDatum> : OutputStream {
//
//    typealias Datum = [SourceDatum]
//
//    init<SourceStream: OutputStream>(
//        source: SourceStream,
//        count: Int,
//        stride: Int,
//        padding: @escaping @autoclosure () -> SourceDatum?
//    ) where SourceStream.Datum == SourceDatum {
//
//        self.source = source.erase()
//        self.count = count
//        self.stride = stride
//        self.padding = padding
//
//        self.buffer = [SourceDatum](initialCapacity: count)
//    }
//
//    func hasMore() async throws -> Bool {
//
//        if self.buffer.count == count {
//            return true
//        }
//        if try await readAhead() != nil {
//            return true
//        }
//        return false
//    }
//
//    func read() async throws -> Datum {
//
//        if self.buffer.count == count {
//            let buffer = self.buffer
//            self.buffer.removeFirst(min(stride, buffer.count))
//            return buffer
//        }
//        if let buffer = try await readAhead() {
//            return buffer
//        }
//        throw EndOfStreamError()
//    }
//
//    func skip(count: Int) async throws -> Int {
//
//        for skipped in 0..<count {
//            guard try await readAhead() != nil else {
//                return skipped
//            }
//        }
//
//        return count
//    }
//
//    private func readAhead() async throws -> [SourceDatum]? {
//
//        if skipAhead > 0 {
//            guard try await skip(count: skipAhead) == skipAhead else {
//                return nil
//            }
//        }
//
//        skipAhead = max(stride - count, 0)
//
//        guard try await source.hasMore() else {
//            return nil
//        }
//
//        let readCount = count - buffer.count
//        let readResult: [SourceDatum] = try await source.read(count: readCount)
//        buffer.append(contentsOf: readResult)
//
//        if buffer.count == count {
//            return buffer
//        }
//
//        if let padding = self.padding() {
//            buffer.append(contentsOf: [SourceDatum](repeating: padding, count: count - buffer.count))
//            return buffer
//        }
//
//        return nil
//    }
//
//    private let source: AnyOutputStream<SourceDatum>
//    private let count: Int
//    private let stride: Int
//    private let padding: () -> SourceDatum?
//
//    private var buffer: [SourceDatum]
//    private var skipAhead = 0
//}
//
//extension Array {
//
//    init(initialCapacity: Int) {
//
//        self.init()
//        reserveCapacity(initialCapacity)
//    }
//}
