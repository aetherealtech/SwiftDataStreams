//
// Created by Daniel Coleman on 11/19/21.
//

import Foundation

typealias ByteInputStream = AnyInputStream<UInt8>
typealias ByteOutputStream = AnyOutputStream<UInt8>

extension InputStream where Datum == UInt8 {

    func fixedWidthInts<Result: FixedWidthInteger>(
        endianess: Endianness = .platform
    ) -> AnyInputStream<Result>  {

        self
            .collect(count: Result.byteCount)
            .map { bytes in try Result(bytes: bytes, endianness: endianess) }
    }
}

extension InputStream where Datum: FixedWidthInteger {

    func bytes(
        endianess: Endianness = .platform
    ) -> ByteInputStream  {

        self
            .flatMap { value in value.bytes(endianness: endianess)  }
    }
}

extension OutputStream where Datum: FixedWidthInteger {

    func bytes(
        endianess: Endianness = .platform
    ) -> ByteOutputStream  {

        self
            .map { bytes in try Datum(bytes: bytes, endianness: endianess) }
            .collect(count: Datum.byteCount)
    }
}

extension OutputStream where Datum == UInt8 {

    func fixedWidthInts<Result: FixedWidthInteger>(
        endianess: Endianness = .platform
    ) -> AnyOutputStream<Result>  {

        self
            .flatMap { value in value.bytes(endianness: endianess) }
    }
}

enum Endianness {

    case bigEndian
    case littleEndian

    static var platform : Endianness {

        #if _endian(big)
        return .bigEndian
        #else
        return .littleEndian
        #endif
    }
}

extension FixedWidthInteger {

    static var byteCount: Int {

        bitWidth / 4
    }

    init(value: Self, endianness: Endianness) {

        switch endianness {

        case .bigEndian:
             self.init(bigEndian: value)

        case .littleEndian:
            self.init(littleEndian: value)
        }
    }

    func value(endianness: Endianness) -> Self {

        switch endianness {

        case .bigEndian:
            return bigEndian

        case .littleEndian:
            return littleEndian
        }
    }

    init<ByteSequence: Sequence>(bytes: ByteSequence, endianness: Endianness = .platform) throws where ByteSequence.Element == UInt8 {

        try self.init(contiguousBytes: Array(bytes.prefix(Self.byteCount)))
    }

    init(contiguousBytes: [UInt8], endianness: Endianness = .platform) throws {

        guard contiguousBytes.count == Self.byteCount else {
            throw NSError(domain: "", code: 0, userInfo: [NSDebugDescriptionErrorKey: "Invalid number of bytes.  Expected \(Self.byteCount), got \(contiguousBytes.count)"])
        }

        let value = withUnsafePointer(to: contiguousBytes) { bytesPtr in
            bytesPtr.withMemoryRebound(to: Self.self, capacity: 1) { valuePtr in
                valuePtr.pointee
            }
        }

        self.init(value: value, endianness: endianness)
    }

    func bytes(endianness: Endianness = .platform) -> [UInt8] {

        let value = self.value(endianness: endianness)

        return withUnsafePointer(to: value) { valuePtr in
            valuePtr.withMemoryRebound(to: UInt8.self, capacity: Self.byteCount) { bytesPtr in
                let bufferPtr = UnsafeBufferPointer(start: bytesPtr, count: Self.byteCount)
                return Array(bufferPtr)
            }
        }
    }
}