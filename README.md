# 🧳 Distributed Tracing Baggage Core

> 📔 **NOTE**: It is very unlikely that you want to depend on _this_ package itself. 
>
> Most libraries and projects should depend on and use the https://github.com/apple/swift-distributed-tracing-baggage package instead, 
> unless avoiding the `SwiftLog` dependency is necessary.

`Baggage` is a minimal (zero-dependency) context propagation container, intended to "carry" baggage items
for purposes of cross-cutting tools to be built on top of it.

It is modeled after the concepts explained in [W3C Baggage](https://w3c.github.io/baggage/) and the 
in the spirit of [Tracing Plane](https://cs.brown.edu/~jcmace/papers/mace18universal.pdf) 's "Baggage Context" type,
although by itself it does not define a specific serialization format. 
 
Please refer to [Swift Distributed Tracing Baggage](https://github.com/apple/swift-distributed-tracing-baggage) 
and [Swift Distributed Tracing](https://github.com/apple/swift-distributed-tracing) for usage guides of this type.

## Dependency

 In order to depend on this library you can use the Swift Package Manager, and add the following dependency to your `Package.swift`:

```swift
dependencies: [
  .package(
    name: "swift-baggage-context-core",
    url: "https://github.com/apple/swift-distributed-tracing-baggage-core.git",
    from: "0.1.0"
  )
]
```

and depend on the module in your target:

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

Please refer to [Swift Distributed Tracing Baggage](https://github.com/apple/swift-distributed-tracing-baggage) for the intended usage,
and detailed guidelines.

Alternatively, please refer to the API documentation of the Baggage type.

## Contributing

Please make sure to run the `./scripts/soundness.sh` script when contributing, it checks formatting and similar things.

You can make ensure it always is run and passes before you push by installing a pre-push hook with git:

```
echo './scripts/soundness.sh' > .git/hooks/pre-push
```
