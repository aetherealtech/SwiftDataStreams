//
// Created by Daniel Coleman on 11/19/21.
//

import Foundation

class Reference<T> {

    init(_ value: T) {

        self.value = value
    }

    var value: T
}

class AsyncToSyncIterator<Source: AsyncIteratorProtocol> : IteratorProtocol {

    typealias Element = Source.Element

    init(source: inout Source) {

        self.source = source
    }

    func next() -> Element? {

        try? Task {

            try await source.next()

        }.synchronousValue
    }

    private var source: Source
}

extension Task {

    var synchronousValue: Success {

        get throws {

            switch synchronousResult {

            case .success(let value):
                return value

            case .failure(let error):
                throw error
            }
        }
    }

    var synchronousResult: Result<Success, Failure> {

        let result = Reference<Result<Success, Failure>?>(nil)

        let semaphore = DispatchSemaphore(value: 0)

        Task<Void, Never> {

            result.value = await self.result

            semaphore.signal()
        }

        semaphore.wait()

        return result.value!
    }
}