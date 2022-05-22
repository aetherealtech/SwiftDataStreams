//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

extension OutputStream {

    public func collect<Element>(
        count: Int,
        padding: @escaping @autoclosure () -> Element? = nil
    ) -> AnyOutputStream<Element> where Datum == [Element] {

        collect(
            count: count,
            stride: count,
            padding: padding()
        )
    }

    public func collect<Element>(
        count: Int,
        stride: Int,
        padding: @escaping @autoclosure () -> Element? = nil
    ) -> AnyOutputStream<Element> where Datum == [Element] {

        CollectedOutputStream(
            dest: self,
            count: count,
            stride: stride,
            padding: padding()
        ).erase()
    }
}

class CollectedOutputStream<Datum> : OutputStream {

    init<DestStream: OutputStream>(
        dest: DestStream,
        count: Int,
        stride: Int,
        padding: @escaping @autoclosure () -> Datum?
    ) where DestStream.Datum == [Datum] {

        self.dest = dest.erase()
        self.count = count
        self.stride = stride
        self.padding = padding
    }

    func write(_ datum: Datum) async throws {

        if skipAhead == 0 {

            buffer.append(datum)

            if buffer.count == count {
                try await dest.write(buffer)
                advance()
            }
        } else {

            skipAhead -= 1
        }
    }

    func flush() async throws {

        if let padding = self.padding() {

            buffer.append(contentsOf: Array(repeating: padding, count: count - buffer.count))
            try await dest.write(buffer)
        }

        try await dest.flush()
    }

    private func advance() {

        buffer.removeFirst(Swift.min(stride, buffer.count))
        skipAhead = Swift.max(stride - count, 0)
    }

    private let dest: AnyOutputStream<[Datum]>
    private let count: Int
    private let stride: Int
    private let padding: () -> Datum?

    private var buffer = [Datum]()
    private var skipAhead = 0
}
