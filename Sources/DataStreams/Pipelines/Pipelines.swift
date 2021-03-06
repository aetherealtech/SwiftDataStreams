//
// Created by Daniel Coleman on 2/19/22.
//

import Foundation

extension InputStream {

    public func connect<Output: OutputStream>(to destination: Output) -> Task<Void, Error> where Output.Datum == Datum {

        Task {

            for try await datum in self {

                guard !Task.isCancelled else {
                    break
                }

                try await destination.write(datum)
            }

            try await destination.flush()
        }
    }

    public func connect<Output: OutputStream>(to destination: Output, limit: UInt64) -> Task<Void, Error> where Output.Datum == Datum {

        Task {

            if limit == 0 {
                return
            }

            var count = UInt64(0)

            for try await datum in self {

                guard !Task.isCancelled else {
                    break
                }

                try await destination.write(datum)
                count += 1

                if count == limit {
                    break
                }
            }

            try await destination.flush()
        }
    }
}