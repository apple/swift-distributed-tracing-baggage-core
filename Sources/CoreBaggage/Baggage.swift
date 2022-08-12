//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Distributed Tracing Baggage open source project
//
// Copyright (c) 2020-2022 Apple Inc. and the Swift Distributed Tracing Baggage project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

// ==== ----------------------------------------------------------------------------------------------------------------
// MARK: Baggage

/// A `Baggage` is a heterogeneous storage type with value semantics for keyed values in a type-safe fashion.
///
/// Its values are uniquely identified via ``BaggageKey``s (by type identity). These keys also dictate the type of
/// value allowed for a specific key-value pair through their associated type `Value`.
///
/// ## Defining keys and accessing values
/// Baggage keys are defined as types, most commonly case-less enums (as no actual instances are actually required)
/// which conform to the ``BaggageKey`` protocol:
///
///     private enum TestIDKey: Baggage.Key {
///       typealias Value = String
///     }
///
/// While defining a key, one should also immediately declare an extension on `Baggage`,
/// to allow convenient and discoverable ways to interact with the baggage item, the extension should take the form of:
///
///     extension Baggage {
///       var testID: String? {
///         get {
///           self[TestIDKey.self]
///         } set {
///           self[TestIDKey.self] = newValue
///         }
///       }
///     }
///
/// For consistency, it is recommended to name key types with the `...Key` suffix (e.g. `SomethingKey`) and the property
/// used to access a value identifier by such key the prefix of the key (e.g. `something`). Please also observe the usual
/// Swift naming conventions, e.g. prefer `ID` to `Id` etc.
///
/// ## Usage
/// Using a baggage container is fairly straight forward, as it boils down to using the prepared computed properties:
///
///     var baggage = Baggage.topLevel
///     // set a new value
///     baggage.testID = "abc"
///     // retrieve a stored value
///     let testID = baggage.testID ?? "default"
///     // remove a stored value
///     baggage.testIDKey = nil
///
/// Note that normally a baggage should not be "created" ad-hoc by user code, but rather it should be passed to it from
/// a runtime. For example, when working in an HTTP server framework, it is most likely that the baggage is already passed
/// directly or indirectly (e.g. in a `FrameworkContext`)
///
/// ### Accessing all values
///
/// The only way to access "all" values in a baggage context is by using the `forEach` function.
/// The baggage container on purpose does not expose more functions to prevent abuse and treating it as too much of an
/// arbitrary value smuggling container, but only make it convenient for tracing and instrumentation systems which need
/// to access either specific or all items carried inside a baggage.
public struct Baggage {
    public typealias Key = BaggageKey

    private var _storage = [AnyBaggageKey: Any]()

    /// Internal on purpose, please use ``Baggage/TODO(_:function:file:line:)`` or ``Baggage/topLevel`` to create an "empty" context,
    /// which carries more meaning to other developers why an empty context was used.
    init() {}
}

extension Baggage {
    /// Creates a new empty "top level" baggage, generally used as an "initial" baggage to immediately be populated with
    /// some values by a framework or runtime. Another use case is for tasks starting in the "background" (e.g. on a timer),
    /// which don't have a "request context" per se that they can pick up, and as such they have to create a "top level"
    /// baggage for their work.
    ///
    /// ## Usage in frameworks and libraries
    /// This function is really only intended to be used frameworks and libraries, at the "top-level" where a request's,
    /// message's or task's processing is initiated. For example, a framework handling requests, should create an empty
    /// context when handling a request only to immediately populate it with useful trace information extracted from e.g.
    /// request headers.
    ///
    /// ## Usage in applications
    /// Application code should never have to create an empty context during the processing lifetime of any request,
    /// and only should create contexts if some processing is performed in the background - thus the naming of this property.
    ///
    /// Usually, a framework such as an HTTP server or similar "request handler" would already provide users
    /// with a context to be passed along through subsequent calls.
    ///
    /// If unsure where to obtain a context from, prefer using `.TODO("Not sure where I should get a context from here?")`,
    /// in order to inform other developers that the lack of context passing was not done on purpose, but rather because either
    /// not being sure where to obtain a context from, or other framework limitations -- e.g. the outer framework not being
    /// baggage context aware just yet.
    public static var topLevel: Baggage {
        return Baggage()
    }
}

extension Baggage {
    /// A baggage intended as a placeholder until a real value can be passed through a function call.
    ///
    /// It should ONLY be used while prototyping or when the passing of the proper context is not yet possible,
    /// e.g. because an external library did not pass it correctly and has to be fixed before the proper context
    /// can be obtained where the TO-DO is currently used.
    ///
    /// ## Crashing on TO-DO context creation
    /// You may set the `BAGGAGE_CRASH_TODOS` variable while compiling a project in order to make calls to this function crash
    /// with a fatal error, indicating where a to-do baggage context was used. This comes in handy when wanting to ensure that
    /// a project never ends up using with code initially was written as "was lazy, did not pass context", yet the
    /// project requires context passing to be done correctly throughout the application. Similar checks can be performed
    /// at compile time easily using linters (not yet implemented), since it is always valid enough to detect a to-do context
    /// being passed as illegal and warn or error when spotted.
    ///
    /// ## Example
    ///
    ///     let baggage = Baggage.TODO("The framework XYZ should be modified to pass us a context here, and we'd pass it along"))
    ///
    /// - Parameters:
    ///   - reason: Informational reason for developers, why a placeholder context was used instead of a proper one,
    /// - Returns: Empty "to-do" baggage context which should be eventually replaced with a carried through one, or `background`.
    public static func TODO(_ reason: StaticString? = "", function: String = #function, file: String = #file, line: UInt = #line) -> Baggage {
        var context = Baggage.topLevel
        #if BAGGAGE_CRASH_TODOS
        fatalError("BAGGAGE_CRASH_TODOS: at \(file):\(line) (function \(function)), reason: \(reason)")
        #else
        context[TODOKey.self] = .init(file: file, line: line)
        return context
        #endif
    }

    private enum TODOKey: BaggageKey {
        typealias Value = TODOLocation
        static var nameOverride: String? {
            return "todo"
        }
    }
}

extension Baggage {
    /// Provides type-safe access to the baggage's values.
    /// This API should ONLY be used inside of accessor implementations.
    ///
    /// End users rather than using this subscript should use "accessors" the key's author MUST define, following this pattern:
    ///
    ///     internal enum TestID: Baggage.Key {
    ///         typealias Value = TestID
    ///     }
    ///
    ///     extension Baggage {
    ///       public internal(set) var testID: TestID? {
    ///         get {
    ///           self[TestIDKey.self]
    ///         }
    ///         set {
    ///           self[TestIDKey.self] = newValue
    ///         }
    ///       }
    ///     }
    ///
    /// This is in order to enforce a consistent style across projects and also allow for fine grained control over
    /// who may set and who may get such property. Just access control to the Key type itself lacks such fidelity.
    ///
    /// Note that specific baggage and context types MAY (and usually do), offer also a way to set baggage values,
    /// however in the most general case it is not required, as some frameworks may only be able to offer reading.
    public subscript<Key: BaggageKey>(_ key: Key.Type) -> Key.Value? {
        get {
            guard let value = self._storage[AnyBaggageKey(key)] else { return nil }
            // safe to force-cast as this subscript is the only way to set a value.
            return (value as! Key.Value)
        }
        set {
            self._storage[AnyBaggageKey(key)] = newValue
        }
    }

    /// Number of contained baggage items.
    public var count: Int {
        return self._storage.count
    }

    public var isEmpty: Bool {
        return self._storage.isEmpty
    }

    /// Calls the given closure for each item contained in the underlying `Baggage`.
    ///
    /// Order of those invocations is NOT guaranteed and should not be relied on.
    ///
    /// - Parameter body: A closure invoked with the type erased key and value stored for the key in this baggage.
    public func forEach(_ body: (AnyBaggageKey, Any) throws -> Void) rethrows {
        try self._storage.forEach { key, value in
            try body(key, value)
        }
    }
}

extension Baggage: CustomStringConvertible {
    /// A context's description prints only keys of the contained values.
    /// This is in order to prevent spilling a lot of detailed information of carried values accidentally.
    ///
    /// `Baggage`s are not intended to be printed "raw" but rather inter-operate with tracing, logging and other systems,
    /// which can use the `forEach` function providing access to its underlying values.
    public var description: String {
        return "\(type(of: self).self)(keys: \(self._storage.map { $0.key.name }))"
    }
}

/// Carried automatically by a "to do" baggage.
/// It can be used to track where a context originated and which "to do" context must be fixed into a real one to avoid this.
public struct TODOLocation {
    /// Source file location where the to-do `Baggage` was created
    public let file: String
    /// Source line location where the to-do `Baggage` was created
    public let line: UInt
}
