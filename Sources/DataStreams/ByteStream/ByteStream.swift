//
// Created by Daniel Coleman on 11/19/21.
//

import Foundation

public typealias ByteInputStream = AnyInputStream<UInt8>
public typealias ByteOutputStream = AnyOutputStream<UInt8>

extension InputStream where Datum == UInt8 {

    public func fixedWidthInts<Result: FixedWidthInteger>(
        endianness: Endianness = .platform
    ) -> AnyInputStream<Result>  {

        self
            .collect(count: Result.byteCount)
            .map { bytes in try Result(bytes: bytes, endianness: endianness) }
    }

    public func asUInt16(
        endianness: Endianness = .platform
    ) -> AnyInputStream<UInt16>  {

        fixedWidthInts(endianness: endianness)
    }

    public func asUInt32(
        endianness: Endianness = .platform
    ) -> AnyInputStream<UInt32>  {

        fixedWidthInts(endianness: endianness)
    }
}

extension InputStream where Datum: FixedWidthInteger {

    public func bytes(
        endianness: Endianness = .platform
    ) -> ByteInputStream  {

        self
            .flatMap { value in value.bytes(endianness: endianness)  }
    }
}

extension OutputStream where Datum: FixedWidthInteger {

    public func bytes(
        endianness: Endianness = .platform
    ) -> ByteOutputStream  {

        self
            .map { bytes in try Datum(bytes: bytes, endianness: endianness) }
            .collect(count: Datum.byteCount)
    }
}

extension OutputStream where Datum == UInt8 {

    public func fixedWidthInts<Result: FixedWidthInteger>(
        endianness: Endianness = .platform
    ) -> AnyOutputStream<Result>  {

        self
            .flatMap { value in value.bytes(endianness: endianness) }
    }

    public func asUInt16(
        endianness: Endianness = .platform
    ) -> AnyOutputStream<UInt16>  {

        fixedWidthInts(endianness: endianness)
    }

    public func asUInt32(
        endianness: Endianness = .platform
    ) -> AnyOutputStream<UInt32>  {

        fixedWidthInts(endianness: endianness)
    }
}

public enum Endianness {

    case bigEndian
    case littleEndian

    public static var platform : Endianness {

        #if _endian(big)
        return .bigEndian
        #else
        return .littleEndian
        #endif
    }
}

extension FixedWidthInteger {

    public static var byteCount: Int {

        bitWidth / 4
    }

    public init(value: Self, endianness: Endianness) {

        switch endianness {

        case .bigEndian:
             self.init(bigEndian: value)

        case .littleEndian:
            self.init(littleEndian: value)
        }
    }

    public func value(endianness: Endianness) -> Self {

        switch endianness {

        case .bigEndian:
            return bigEndian

        case .littleEndian:
            return littleEndian
        }
    }

    public init<ByteSequence: Sequence>(bytes: ByteSequence, endianness: Endianness = .platform) throws where ByteSequence.Element == UInt8 {

        try self.init(contiguousBytes: Array(bytes.prefix(Self.byteCount)))
    }

    public init(contiguousBytes: [UInt8], endianness: Endianness = .platform) throws {

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

    public func bytes(endianness: Endianness = .platform) -> [UInt8] {

        let value = self.value(endianness: endianness)

        return withUnsafePointer(to: value) { valuePtr in
            valuePtr.withMemoryRebound(to: UInt8.self, capacity: Self.byteCount) { bytesPtr in
                let bufferPtr = UnsafeBufferPointer(start: bytesPtr, count: Self.byteCount)
                return Array(bufferPtr)
            }
        }
    }
}