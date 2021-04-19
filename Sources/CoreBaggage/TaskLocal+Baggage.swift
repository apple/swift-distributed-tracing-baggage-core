//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Distributed Tracing Baggage open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift Distributed Tracing Baggage project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

#if compiler(>=5.5) // we cannot write this on one line with `&&` because Swift 5.0 doesn't like it...
#if compiler(>=5.5) && $AsyncAwait
import _Concurrency

@available(macOS 9999, iOS 9999, watchOS 9999, tvOS 9999, *)
extension TaskLocalValues {
    public struct BaggageKey: TaskLocalKey {
        public static var defaultValue: Baggage { Baggage.topLevel }
    }

    public var baggage: BaggageKey { .init() }
}
#endif
#endif
