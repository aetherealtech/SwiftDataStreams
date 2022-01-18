//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation

import CoreExtensions

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension InputStream where Datum: InputStream {

    public func flatten() -> AnyInputStream<Datum.Datum> {

        FlattenInputStream(
            source: self
        ).erase()
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Sequence where Element: InputStream {

    public func flatten() -> AnyInputStream<Element.Datum> {

        self.asStream()
            .flatten()
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
class FlattenInputStream<SourceStream: InputStream> : InputStream where SourceStream.Datum: InputStream {

    typealias Datum = SourceStream.Datum.Datum

    init(
        source: SourceStream
    ) {

        self.outerSource = source.erase()
    }

    func hasMore() async throws -> Bool {

        do {

            return try await getInnerSource().hasMore()

        } catch is EndOfStreamError {

            return false
        }
    }

    func read() async throws -> Datum {

        return try await getInnerSource().read()
    }

    func skip(count: Int) async throws -> Int {

        guard count > 0 else { return 0 }

        var remaining = count

        do {

            while remaining > 0 {

                let innerSource = try await getInnerSource()
                remaining -= try await innerSource.skip(count: remaining)
            }

        } catch is EndOfStreamError {


        }

        return count - remaining
    }

    private func getInnerSource() async throws -> AnyInputStream<Datum> {

        if let innerSource = self.innerSource, try await innerSource.hasMore() {
            return innerSource
        }
        
        let innerSource = try await outerSource.read().erase()
        self.innerSource = innerSource
        return innerSource
    }

    private let outerSource: AnyInputStream<SourceStream.Datum>
    private var innerSource: AnyInputStream<Datum>?
}
