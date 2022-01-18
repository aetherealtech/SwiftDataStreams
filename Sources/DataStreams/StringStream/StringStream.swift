//
// Created by Daniel Coleman on 11/19/21.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
typealias StringStream = AnyInputStream<Character>

class UnicodeEncodeError : Error {

}

class UnicodeDecodeError : Error {

}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension InputStream where Datum == Unicode.UTF8.CodeUnit {

    func utf8String() -> UnicodeEncodingStream<Unicode.UTF8> {

        UnicodeEncodingStream(source: self)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension InputStream where Datum == Unicode.UTF16.CodeUnit {

    func utf16String() -> UnicodeEncodingStream<Unicode.UTF16> {

        UnicodeEncodingStream(source: self)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension InputStream where Datum == Unicode.UTF32.CodeUnit {

    func utf32String() -> UnicodeEncodingStream<Unicode.UTF32> {

        UnicodeEncodingStream(source: self)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class UnicodeEncodingStream<Codec: UnicodeCodec> : InputStream {

    typealias Datum = Character

    convenience init<Source: InputStream>(
        source: Source
    ) where Codec == Unicode.UTF8, Source.Datum == Codec.CodeUnit {

        self.init(
            source: source,
            codec: Unicode.UTF8()
        )
    }

    convenience init<Source: InputStream>(
        source: Source
    ) where Codec == Unicode.UTF16, Source.Datum == Codec.CodeUnit {

        self.init(
            source: source,
            codec: Unicode.UTF16()
        )
    }

    convenience init<Source: InputStream>(
        source: Source
    ) where Codec == Unicode.UTF32, Source.Datum == Codec.CodeUnit {

        self.init(
            source: source,
            codec: Unicode.UTF32()
        )
    }

    init<Source: InputStream>(
        source: Source,
        codec: Codec
    ) where Source.Datum == Codec.CodeUnit {

        self.source = source.erase()
        self.codec = codec
    }

    func hasMore() async throws -> Bool {

        if nextCharacter != nil {
            return true
        }
        nextCharacter = try await getNextCharacter()
        return nextCharacter != nil
    }

    func read() async throws -> Character {

        if let next = self.nextCharacter {
            self.nextCharacter = nil
            return next
        }

        guard let next = try await getNextCharacter() else {
            throw EndOfStreamError()
        }

        return next
    }

    func skip(count: Int) async throws -> Int {

        var skipped = 0

        while skipped < count {
            guard try await hasMore() else { break }
            _ = try await read()
            skipped += 1
        }

        return skipped
    }

    private func getNextCharacter() async throws -> Character? {

        while buffer.buffer.count < bufferSize {
            guard try await source.hasMore() else { break }
            buffer.buffer.append(try await source.read())
        }

        let result = self.codec.decode(&buffer)

        switch result {

        case .scalarValue(let value):
            return Character(value)

        case .emptyInput:
            return nil

        case .error:
            throw UnicodeDecodeError()
        }
    }

    private class Buffer: IteratorProtocol {

        typealias Element = Codec.CodeUnit

        func next() -> Codec.CodeUnit? {

            guard !buffer.isEmpty else { return nil }

            return buffer.removeFirst()
        }

        var buffer: [Codec.CodeUnit] = []
    }

    private var bufferSize: Int { 4 / MemoryLayout<Codec.CodeUnit>.size }

    private let source: AnyInputStream<Codec.CodeUnit>
    private var codec: Codec

    private var buffer = Buffer()
    private var nextCharacter: Character?
}

//class UnicodeEncodingStream<Codec: UnicodeCodec> : InputStream {
//
//    typealias Datum = Character
//
//    convenience init<Source: InputStream>(
//        source: Source
//    ) where Codec == Unicode.UTF8, Source.Datum == Codec.CodeUnit {
//
//        self.init(
//            source: source,
//            codec: Unicode.UTF8()
//        )
//    }
//
//    convenience init<Source: InputStream>(
//        source: Source
//    ) where Codec == Unicode.UTF16, Source.Datum == Codec.CodeUnit {
//
//        self.init(
//            source: source,
//            codec: Unicode.UTF16()
//        )
//    }
//
//    convenience init<Source: InputStream>(
//        source: Source
//    ) where Codec == Unicode.UTF32, Source.Datum == Codec.CodeUnit {
//
//        self.init(
//            source: source,
//            codec: Unicode.UTF32()
//        )
//    }
//
//    init<Source: InputStream>(
//        source: Source,
//        codec: Codec
//    ) where Source.Datum == Codec.CodeUnit {
//
//        self.source = source.erase()
//        self.syncSource = AsyncToSyncIterator(source: &self.source)
//
//        self.codec = codec
//    }
//
//    func hasMore() async throws -> Bool {
//
//        try await source.hasMore()
//    }
//
//    func read() async throws -> Character {
//
//        try await withCheckedThrowingContinuation { continuation in
//
//            self.readThread.schedule {
//
//                let result = self.codec.decode(&self.syncSource)
//
//                switch result {
//
//                case .scalarValue(let value):
//                    continuation.resume(returning: Character(value))
//
//                case .emptyInput:
//                    continuation.resume(throwing: EndOfStreamError())
//
//                case .error:
//                    continuation.resume(throwing: UnicodeDecodeError())
//                }
//            }
//        }
//    }
//
//    func skip(count: Int) async throws -> Int {
//
//        var skipped = 0
//
//        while skipped < count {
//            guard try await hasMore() else { break }
//            _ = try await read()
//            skipped += 1
//        }
//
//        return skipped
//    }
//
//    private var source: AnyInputStream<Codec.CodeUnit>
//    private var syncSource: AsyncToSyncIterator<Codec.CodeUnit>
//
//    private var codec: Codec
//
//    private let readThread = LoopingThread()
//}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension InputStream where Datum == Character {

    func utf8Characters() -> UnicodeDecodingStream<Unicode.UTF8> {

        UnicodeDecodingStream(source: self)
    }

    func utf16Characters() -> UnicodeDecodingStream<Unicode.UTF16> {

        UnicodeDecodingStream(source: self)
    }

    func utf32Characters() -> UnicodeDecodingStream<Unicode.UTF32> {

        UnicodeDecodingStream(source: self)
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class UnicodeDecodingStream<Codec: UnicodeCodec> : InputStream {

    typealias Datum = Codec.CodeUnit

    init<Source: InputStream>(
        source: Source
    ) where Source.Datum == Character {

        self.source = source.erase()
    }

    func hasMore() async throws -> Bool {

        if current.position < current.characters.count {
            return true
        }

        return try await source.hasMore()
    }

    func read() async throws -> Codec.CodeUnit {

        if current.position == current.characters.count {
            
            try await readNextCharacter()
        }

        let result = current.characters[current.position]
        current.position = current.position + 1

        return result
    }

    func skip(count: Int) async throws -> Int {

        let skipped = Swift.min(count, current.characters.count - current.position)
        current.position += skipped

        let remaining = count - skipped
        guard remaining > 0 else {
            return skipped
        }

        try await readNextCharacter()
        return skipped + (try await skip(count: remaining))
    }

    private func readNextCharacter() async throws {

        let scalars = try await source.read().unicodeScalars

        for scalar in scalars {
            guard let encoded = Codec.encode(scalar) else {
                throw UnicodeEncodeError()
            }

            current.characters = [Codec.CodeUnit](encoded)
            current.position = 0
        }
    }

    private class Current {

        init() {

            self.characters = [Codec.CodeUnit]()
            self.position = 0
        }

        var characters: [Codec.CodeUnit]
        var position: Int
    }

    private let source: AnyInputStream<Character>
    private let current = Current()
}
