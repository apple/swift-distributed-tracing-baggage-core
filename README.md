# 🧳 Distributed Tracing Baggage Core

`Baggage` is a minimal (zero-dependency) context propagation container, intended to "carry" baggage items
for purposes of cross-cutting tools to be built on top of it.

It is modeled after the concepts explained in [W3C Baggage](https://w3c.github.io/baggage/) and the 
in the spirit of [Tracing Plane](https://cs.brown.edu/~jcmace/papers/mace18universal.pdf) baggage context type,
 although by itself it does not define a specific serialization format. 
 
Please refer to [Swift Distributed Tracing Baggage](https://github.com/apple/swift-distributed-tracing-baggage) 
and [Swift Distributed Tracing](https://github.com/apple/swift-distributed-tracing) for usage guides of this type.


## Dependencies

It should be noted that most libraries and frameworks do NOT need to depend on this package explicitly,
but rather should depend on [Swift Distributed Tracing Baggage](https://github.com/apple/swift-distributed-tracing-baggage) or [Swift Distributed Tracing](https://github.com/apple/swift-distributed-tracing) which will pull the
`CoreBaggage` via their transitive dependencies. This package and the `CoreBaggage` module exist only for
libraries which want to maintain an absolutely minimal dependency footprint, and e.g. do not want to depend on `Logging` modules, which the higher level packages may do.

## Installation

You can install the `BaggageContext` library through the Swift Package Manager. The library itself is called `Baggage`,
so that's what you'd import in your Swift files.

```swift
dependencies: [
  .package(
    name: "swift-baggage-context-core",
    url: "https://github.com/apple/swift-distributed-tracing-baggage-core.git",
    from: "0.3.0"
  )
]
```

and depend on the module:

```swift 
targets: [
    .target(
        name: "MyAwesomeApp",
        dependencies: [
            "CoreBaggage",
        ]
    ),
    // ... 
]
```

## Usage

Please refer to [Swift Distributed Tracing Baggage](https://github.com/apple/swift-distributed-tracing-baggage) for the intended usage.


## Contributing

Please make sure to run the `./scripts/sanity.sh` script when contributing, it checks formatting and similar things.

You can make ensure it always is run and passes before you push by installing a pre-push hook with git:

```
echo './scripts/sanity.sh' > .git/hooks/pre-push
```
