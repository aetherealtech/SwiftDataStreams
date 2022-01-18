//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public class CollectionInputOutputStream<Source: RangeReplaceableCollection> : CollectionInputStream<Source>, OutputStream {

    public func write(_ datum: Datum) async throws {

        if currentIndex < data.endIndex {
            data.replaceSubrange(currentIndex..<data.index(currentIndex, offsetBy: 1), with: [datum])
        }
        else {
            data.append(datum)
        }

        advance(1)
    }

    public func flush() async throws {

    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension RangeReplaceableCollection {

    public func asStream() -> CollectionInputOutputStream<Self> {

        CollectionInputOutputStream<Self>(source: self)
    }
}
