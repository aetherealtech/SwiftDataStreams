//
// Created by Daniel Coleman on 11/19/21.
//

import Foundation

public typealias StringInputStream = AnyInputStream<Character>
public typealias StringOutputStream = AnyOutputStream<Character>

extension InputStream where Datum == Character {

    public func unicodeScalars() -> AnyInputStream<UnicodeScalar> {

        self
            .flatMap { character in character.unicodeScalars }
    }
}

extension OutputStream where Datum == UnicodeScalar {

    public func string() -> StringOutputStream {

        self
            .flatMap { character in character.unicodeScalars }
    }
}

extension InputStream where Datum == Character {

    public func bytes(
        encoding: String.Encoding
    ) -> ByteInputStream {
        
        switch encoding {
        
        case .ascii, .utf8:
            return utf8Bytes()
            
        case .utf16:
            return utf16Bytes(endianness: .platform)
            
        case .utf16BigEndian:
            return utf16Bytes(endianness: .bigEndian)
            
        case .utf16LittleEndian:
            return utf16Bytes(endianness: .littleEndian)
            
        case .utf32:
            return utf32Bytes(endianness: .platform)

        case .utf32BigEndian:
            return utf32Bytes(endianness: .bigEndian)

        case .utf32LittleEndian:
            return utf32Bytes(endianness: .littleEndian)
            
        default:
            fatalError("String encoding \(encoding.description) not supported")
        }
    }

    public func utf8Bytes() -> ByteInputStream {

        self
            .utf8CodePoints()
            .erase()
    }

    public func utf16Bytes(
        endianness: Endianness
    ) -> ByteInputStream {

        self
            .utf16CodePoints()
            .bytes(endianness: endianness)
            .erase()
    }

    public func utf32Bytes(
        endianness: Endianness
    ) -> ByteInputStream {

        self
            .utf32CodePoints()
            .bytes(endianness: endianness)
            .erase()
    }
}

extension InputStream where Datum == UInt8 {

    public func string(
        encoding: String.Encoding
    ) -> StringInputStream {

        switch encoding {

        case .ascii, .utf8:
            return utf8String()

        case .utf16:
            return utf16String(endianness: .platform)

        case .utf16BigEndian:
            return utf16String(endianness: .bigEndian)

        case .utf16LittleEndian:
            return utf16String(endianness: .littleEndian)

        case .utf32:
            return utf32String(endianness: .platform)

        case .utf32BigEndian:
            return utf32String(endianness: .bigEndian)

        case .utf32LittleEndian:
            return utf32String(endianness: .littleEndian)

        default:
            fatalError("String encoding \(encoding.description) not supported")
        }
    }

    public func utf16String(
        endianness: Endianness
    ) -> StringInputStream {

        self
            .asUInt16(endianness: endianness)
            .utf16String()
            .erase()
    }

    public func utf32String(
        endianness: Endianness
    ) -> StringInputStream {

        self
            .asUInt32(endianness: endianness)
            .utf32String()
            .erase()
    }
}

extension OutputStream where Datum == UInt8 {

    public func string(
        encoding: String.Encoding
    ) -> StringOutputStream {

        switch encoding {

        case .ascii, .utf8:
            return unicodeString()

        case .utf16:
            return utf16String(endianness: .platform)

        case .utf16BigEndian:
            return utf16String(endianness: .bigEndian)

        case .utf16LittleEndian:
            return utf16String(endianness: .littleEndian)

        case .utf32:
            return utf32String(endianness: .platform)

        case .utf32BigEndian:
            return utf32String(endianness: .bigEndian)

        case .utf32LittleEndian:
            return utf32String(endianness: .littleEndian)

        default:
            fatalError("String encoding \(encoding.description) not supported")
        }
    }

    public func utf16String(
        endianness: Endianness
    ) -> StringOutputStream {

        self
            .asUInt16(endianness: endianness)
            .unicodeString()
            .erase()
    }

    public func utf32String(
        endianness: Endianness
    ) -> StringOutputStream {

        self
            .asUInt32(endianness: endianness)
            .unicodeString()
            .erase()
    }
}