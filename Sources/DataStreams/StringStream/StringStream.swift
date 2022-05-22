//
// Created by Daniel Coleman on 11/19/21.
//

import Foundation

typealias StringInputStream = AnyInputStream<Character>
typealias StringOutputStream = AnyOutputStream<Character>

extension InputStream where Datum == Character {

    func unicodeScalars() -> AnyInputStream<UnicodeScalar> {

        self
            .flatMap { character in character.unicodeScalars }
    }
}

extension OutputStream where Datum == UnicodeScalar {

    func string() -> StringOutputStream {

        self
            .flatMap { character in character.unicodeScalars }
    }
}

extension InputStream where Datum == Character {

    func bytes(
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
    
    func utf8Bytes() -> ByteInputStream {

        self
            .utf8CodePoints()
            .erase()
    }

    func utf16Bytes(
        endianness: Endianness
    ) -> ByteInputStream {

        self
            .utf16CodePoints()
            .bytes(endianess: endianness)
            .erase()
    }

    func utf32Bytes(
        endianness: Endianness
    ) -> ByteInputStream {

        self
            .utf32CodePoints()
            .bytes(endianess: endianness)
            .erase()
    }
}

extension InputStream where Datum == UInt8 {

    func string(
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
    
    func utf16String(
        endianness: Endianness
    ) -> StringInputStream {

        self
            .fixedWidthInts(endianess: endianness)
            .utf16String()
            .erase()
    }

    func utf32String(
        endianness: Endianness
    ) -> StringInputStream {

        self
            .fixedWidthInts(endianess: endianness)
            .utf32String()
            .erase()
    }
}

extension OutputStream where Datum == UInt8 {

    func string(
        encoding: String.Encoding
    ) -> StringOutputStream {

        switch encoding {

        case .ascii, .utf8:
            return utf8Characters()

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

    func utf16String(
        endianness: Endianness
    ) -> StringOutputStream {

        self
            .fixedWidthInts(endianess: endianness)
            .utf16Characters()
            .erase()
    }

    func utf32String(
        endianness: Endianness
    ) -> StringOutputStream {

        self
            .fixedWidthInts(endianess: endianness)
            .utf32Characters()
            .erase()
    }
}