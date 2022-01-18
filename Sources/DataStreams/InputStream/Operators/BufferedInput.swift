//
// Created by Daniel Coleman on 11/19/21.
//

import Foundation

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension InputStream {

    func buffered() -> AnySeekableInputStream<Datum> {

        BufferedInputStream(source: self).erase()
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension InputStream where Self: SeekableStream {

    func buffered() -> AnySeekableInputStream<Datum> {

        self.erase()
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class BufferedInputStream<Datum> : SeekableInputStream {

    init<Source: InputStream>(source: Source) where Source.Datum == Datum {

        self.source = source.erase()

        position = 0
        buffer = [Datum]()
    }

    func hasMore() async throws -> Bool {

        if position < buffer.count {
            return true
        }

        return try await source.hasMore()
    }

    func read() async throws -> Datum {

        let result: Datum
        if position < buffer.count {

            result = buffer[position]

        } else {

            result = try await source.read()
            buffer.append(result)
        }

        position += 1
        return result
    }

    func skip(count: Int) async throws -> Int {

        let targetOffset = position + count
        if targetOffset <= buffer.count {

            position = targetOffset
            return count
        }

        let bufferSkip = buffer.count - position
        let readCount = count - bufferSkip
        position = buffer.count

        let result: [Datum] = try await source.read(count: readCount)
        buffer.append(contentsOf: result)

        position = buffer.count
        return bufferSkip + result.count
    }

    func seek(position: Int) async throws -> Bool {

        guard position >= 0 else {
            return false
        }

        if position <= buffer.count {

            self.position = position
            return true
        }

        let currentPosition = self.position

        let requestedSkipped = position - buffer.count
        let actualSkipped = try await skip(count: requestedSkipped)

        if actualSkipped == requestedSkipped {
            return true
        }

        self.position = currentPosition
        return false
    }

    private(set) var position: Int

    private let source: AnyInputStream<Datum>
    private var buffer: [Datum]
}
