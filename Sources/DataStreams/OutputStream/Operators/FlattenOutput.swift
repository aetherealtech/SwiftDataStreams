//
// Created by Daniel Coleman on 5/22/22.
//

import Foundation

extension OutputStream {

    public func flatten<OuterSequence: Sequence>() -> AnyOutputStream<OuterSequence> where OuterSequence.Element == Datum {

        FlattenOutputStream(dest: self)
            .erase()
    }

    public func flatten<OuterSequence: AsyncSequence>() -> AnyOutputStream<OuterSequence> where OuterSequence.Element == Datum {

        FlattenAsyncOutputStream(dest: self)
            .erase()
    }
}

class FlattenOutputStream<Datum: Sequence, DestStream: OutputStream> : OutputStream where DestStream.Datum == Datum.Element {

    init(
        dest: DestStream
    ) {
        self.dest = dest
    }

    func write(_ datum: Datum) async throws {

        try await dest.write(source: datum)
    }

    func flush() async throws {

    }

    private let dest: DestStream
}

class FlattenAsyncOutputStream<Datum: AsyncSequence, DestStream: OutputStream> : OutputStream where DestStream.Datum == Datum.Element {

    init(
        dest: DestStream
    ) {
        self.dest = dest
    }

    func write(_ datum: Datum) async throws {

        try await dest.write(source: datum)
    }

    func flush() async throws {

    }

    private let dest: DestStream
}
