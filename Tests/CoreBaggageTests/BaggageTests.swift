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

import CoreBaggage
import XCTest

final class BaggageTests: XCTestCase {
    func testSubscriptAccess() {
        let testID = 42

        var baggage = Baggage.topLevel
        XCTAssertNil(baggage[TestIDKey.self])

        baggage[TestIDKey.self] = testID
        XCTAssertEqual(baggage[TestIDKey.self], testID)

        baggage[TestIDKey.self] = nil
        XCTAssertNil(baggage[TestIDKey.self])
    }

    func testRecommendedConvenienceExtension() {
        let testID = 42

        var baggage = Baggage.topLevel
        XCTAssertNil(baggage.testID)

        baggage.testID = testID
        XCTAssertEqual(baggage.testID, testID)

        baggage[TestIDKey.self] = nil
        XCTAssertNil(baggage.testID)
    }

    func testEmptyBaggageDescription() {
        XCTAssertEqual(String(describing: Baggage.topLevel), "Baggage(keys: [])")
    }

    func testSingleKeyBaggageDescription() {
        var baggage = Baggage.topLevel
        baggage.testID = 42

        XCTAssertEqual(String(describing: baggage), #"Baggage(keys: ["TestIDKey"])"#)
    }

    func testMultiKeysBaggageDescription() {
        var baggage = Baggage.topLevel
        baggage.testID = 42
        baggage[SecondTestIDKey.self] = "test"

        let description = String(describing: baggage)
        XCTAssert(description.starts(with: "Baggage(keys: ["), "Was: \(description)")
        // use contains instead of `XCTAssertEqual` because the order is non-predictable (Dictionary)
        XCTAssert(description.contains("TestIDKey"), "Was: \(description)")
        XCTAssert(description.contains("ExplicitKeyName"), "Was: \(description)")
    }

    // ==== ------------------------------------------------------------------------------------------------------------
    // MARK: Factories

    func test_todo_context() {
        // the to-do context can be used to record intentions for why a context could not be passed through
        let context = Baggage.TODO("#1245 Some other library should be adjusted to pass us context")
        _ = context // avoid "not used" warning
    }

    func test_topLevel() {
        let context = Baggage.topLevel
        _ = context // avoid "not used" warning
    }
}

private enum TestIDKey: Baggage.Key {
    typealias Value = Int
}

private extension Baggage {
    var testID: Int? {
        get {
            return self[TestIDKey.self]
        }
        set {
            self[TestIDKey.self] = newValue
        }
    }
}

private enum SecondTestIDKey: Baggage.Key {
    typealias Value = String

    static let nameOverride: String? = "ExplicitKeyName"
}
