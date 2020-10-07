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

/// Configures the policy related to values stored using this key.
///
/// This can be used to ensure that a value should never be logged automatically by a logger associated to a context.
///
/// Summary:
/// - `public` - items are accessible by other modules via `baggage.forEach` and direct key lookup,
///    and will be logged by the `LoggingContext` `logger.
/// - `publicExceptLogging` - items are accessible by other modules via `baggage.forEach` and direct key lookup,
///    however will NOT be logged by the `LoggingContext` `logger`.
/// - `private` - items are NOT accessible by other modules via `baggage.forEach` nor are they logged by default.
///    The only way to gain access to a private baggage item is through it's key or accessor, which means that
///    access is controlled using Swift's native access control mechanism, i.e. a `private`/`internal` `Key` and `set` accessor,
///    will result in a baggage item that may only be set by the owning module, but read by anyone via the (`public`) accessor.
public enum BaggageAccessPolicy: Int, Hashable {
    /// Access to this baggage item is NOT restricted.
    /// This baggage item will be listed when `baggage.forEach` is invoked, and thus modules other than the defining
    /// module may gain access to it and potentially log or pass it to other parts of the system.
    ///
    /// Note that this can happen regardless of the key being declared private or internal.
    ///
    /// ### Example
    /// When module `A` defines `AKey` and keeps it `private`, any other module still may call `baggage.forEach`
    case `public` = 0

    /// Access to this baggage item is NOT restricted, however the `LoggingContext` (and any other well-behaved context)
    /// MUST NOT log this baggage item.
    ///
    /// This policy can be useful if some user sensitive value must be carried in baggage context, however it should never
    /// appear in log statements. While usually such items should not be put into baggage, we offer this mode as a way of
    /// threading through a system values which should not be logged nor pollute log statements.
    case publicExceptLogging = 8

    /// Access to this baggage item is RESTRICTED and can only be performed by a direct subscript lookup into the baggage.
    ///
    /// This effectively restricts the access to the baggage item, to any party which has access to the associated
    /// `BaggageKey`. E.g. if the baggage key is defined internal or private, and the `set` accessor is also internal or
    /// private, no other module would be able to modify this baggage once it was set on a baggage context.
    case `private` = 16
}

extension Baggage {
    public typealias AccessPolicy = BaggageAccessPolicy
}
