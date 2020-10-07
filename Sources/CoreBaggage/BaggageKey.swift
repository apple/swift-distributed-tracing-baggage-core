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

/// `BaggageKey`s are used as keys in a `Baggage`. Their associated type `Value` guarantees type-safety.
/// To give your `BaggageKey` an explicit name you may override the `name` property.
///
/// In general, `BaggageKey`s should be `internal` or `private` to the part of a system using it.
///
/// All access to baggage items should be performed through an accessor computed property defined as shown below:
///
///     /// The Key type should be internal (or private).
///     enum TestIDKey: Baggage.Key {
///         typealias Value = String
///         static var nameOverride: String? { "test-id" }
///     }
///
///     extension Baggage {
///         /// This is some useful property documentation.
///         public internal(set) var testID: String? {
///             get {
///                 self[TestIDKey.self]
///             }
///             set {
///                 self[TestIDKey.self] = newValue
///             }
///         }
///     }
///
/// This pattern allows library authors fine-grained control over which values may be set, and whic only get by end-users.
public protocol BaggageKey {
    /// The type of `Value` uniquely identified by this key.
    associatedtype Value

    /// The human-readable name of this key.
    /// This name will be used instead of the type name when a value is printed.
    ///
    /// It MAY also be picked up by an instrument (from Swift Tracing) which serializes baggage items and e.g. used as
    /// header name for carried metadata. Though generally speaking header names are NOT required to use the nameOverride,
    /// and MAY use their well known names for header names etc, as it depends on the specific transport and instrument used.
    ///
    /// For example, a baggage key representing the W3C "trace-state" header may want to return "trace-state" here,
    /// in order to achieve a consistent look and feel of this baggage item throughout logging and tracing systems.
    ///
    /// Defaults to `nil`.
    static var nameOverride: String? { get }

    /// Configures the policy related to values stored using this key.
    ///
    /// This can be used to ensure that a value should never be logged automatically by a logger associated to a context.
    ///
    /// Summary:
    /// - `public` - items are accessible by other modules via `baggage.forEach` and direct key lookup,
    ///    and will be logged by the `LoggingContext` `logger.
    /// - `publicExceptLogging` - items are accessible by other modules via `baggage.forEach` and direct key lookup,
    ///    however will NOT be logged by the `LoggingContext` `logger.
    /// - `private` - items are NOT accessible by other modules via `baggage.forEach` nor are they logged by default.
    ///    The only way to gain access to a private baggage item is through it's key or accessor, which means that
    ///    access is controlled using Swift's native access control mechanism, i.e. a `private`/`internal` `Key` and `set` accessor,
    ///    will result in a baggage item that may only be set by the owning module, but read by anyone via the (`public`) accessor.
    ///
    /// Defaults to `.public`.
    static var access: Baggage.AccessPolicy { get }
}

extension BaggageKey {
    public static var nameOverride: String? { return nil }
    public static var access: Baggage.AccessPolicy { return .public }
}

/// A type-erased `BaggageKey` used when iterating through the `Baggage` using its `forEach` method.
public struct AnyBaggageKey {
    /// The key's type represented erased to an `Any.Type`.
    public let keyType: Any.Type

    public let access: Baggage.AccessPolicy

    private let _nameOverride: String?

    /// A human-readable String representation of the underlying key.
    /// If no explicit name has been set on the wrapped key the type name is used.
    public var name: String {
        return self._nameOverride ?? String(describing: self.keyType.self)
    }

    init<Key>(_ keyType: Key.Type) where Key: BaggageKey {
        self.keyType = keyType
        self._nameOverride = keyType.nameOverride
        self.access = keyType.access
    }
}

extension AnyBaggageKey: CustomStringConvertible {
    public var description: String {
        return "AnyBaggageKey(\(self.name), access: \(self.access))"
    }
}

extension AnyBaggageKey: Hashable {
    public static func == (lhs: AnyBaggageKey, rhs: AnyBaggageKey) -> Bool {
        return ObjectIdentifier(lhs.keyType) == ObjectIdentifier(rhs.keyType)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self.keyType))
    }
}
