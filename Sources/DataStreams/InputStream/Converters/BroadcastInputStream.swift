//
// Created by Daniel Coleman on 11/18/21.
//

import Foundation
import EventStreams
import Observer

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension InputStream {

    public func broadcast() -> EventStream<Datum> {

        EventStream(
            registerValues: { (onValue, onComplete) in

                BroadcastInputStream(
                    source: self,
                    onValue: onValue,
                    onComplete: onComplete
                )
            },
            unregister: { registrant in

            }
        )
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public class BroadcastInputStream<Source: InputStream> {

    public typealias Value = Source.Datum

    init(
        source: Source,
        onValue: @escaping (Value) -> Void,
        onComplete: @escaping () -> Void
    ) {

        Task { [weak self] in

            do {

                for try await value in source {

                    guard self != nil else { break }

                    onValue(value)
                }
            }
            catch {

            }

            onComplete()
        }
    }
}