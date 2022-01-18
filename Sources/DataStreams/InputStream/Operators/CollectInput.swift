//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension InputStream {

    public func collect(
        count: Int,
        padding: @escaping @autoclosure () -> Datum? = nil
    ) -> AnyInputStream<[Datum]> {

        collect(
            count: count,
            stride: count,
            padding: padding()
        )
    }

    public func collect(
        count: Int,
        stride: Int,
        padding: @escaping @autoclosure () -> Datum? = nil
    ) -> AnyInputStream<[Datum]> {

        CollectedInputStream(
            source: self,
            count: count,
            stride: stride,
            padding: padding()
        ).erase()
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class CollectedInputStream<SourceDatum> : InputStream {

    typealias Datum = [SourceDatum]

    init<SourceStream: InputStream>(
        source: SourceStream,
        count: Int,
        stride: Int,
        padding: @escaping @autoclosure () -> SourceDatum?
    ) where SourceStream.Datum == SourceDatum {

        self.source = source.erase()
        self.count = count
        self.stride = stride
        self.padding = padding
    }

    func hasMore() async throws -> Bool {

        do {

            _ = try await getNext()

        } catch is EndOfStreamError {

            return false
        }

        return true
    }

    func read() async throws -> [SourceDatum] {

        let result = try await getNext()
        advance()

        return result
    }

    func skip(count: Int) async throws -> Int {

        var remaining = count

        if !next.isEmpty {
            remaining -= 1
            next.removeAll()
        }

        if remaining > 0 {

            let sourceCount = stride * remaining
            remaining -= try await source.skip(count: sourceCount) / stride
        }

        return count - remaining
    }

    private func getNext() async throws -> [SourceDatum] {

        if next.count == count {
            return next
        }

        if skipAhead > 0 {

            guard try await source.skip(count: skipAhead) == skipAhead else {

                throw EndOfStreamError()
            }
        }

        let remaining = count - next.count
        if remaining > 0 {

            let read: [SourceDatum] = try await source.read(count: remaining)
            
            guard !read.isEmpty else {
                throw EndOfStreamError()
            }
            
            next.append(contentsOf: read)
        }

        if next.count < count {

            guard let padding = self.padding() else {
                throw EndOfStreamError()
            }

            next.append(contentsOf: [SourceDatum](repeating: padding, count: count - next.count))
        }

        return next
    }

    private func advance() {

        next.removeFirst(Swift.min(stride, next.count))
        skipAhead = Swift.max(stride - count, 0)
    }

    private let source: AnyInputStream<SourceDatum>
    private let count: Int
    private let stride: Int
    private let padding: () -> SourceDatum?

    private var next = [SourceDatum]()
    private var skipAhead = 0
}
