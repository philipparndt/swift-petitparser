//
//  TracerTest.swift
//  Tests
//
//  Created by Philipp Arndt on 2019-12-23.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_petitparser

class TracerTest: XCTestCase {
    static let IDENTIFIER: Parser = CP.letter().seq(CP.word().star()).flatten()
    
    func testSuccessfulTrace() {
        let actual = TraceArrayConsumer()
        
        let expected = [
        "FlattenParser",
        "  SequenceParser",
        "    CharacterParser[letter expected]",
        "    Success[1:2]: a",
        "    PossessiveRepeatingParser[0..*]",
        "      CharacterParser[letter or digit expected]",
        "      Failure[1:2]: letter or digit expected",
        "    Success[1:2]: []",
        "  Success[1:2]: [\"a\", []]",
        "Success[1:2]: a"
        ]
        let result = Tracer.on(TracerTest.IDENTIFIER, consumer: actual).parse("a")
        let actualMapped = actual.events.map { "\($0)" }
        
        XCTAssertEqual(expected.count, actualMapped.count)
        for i in 0..<expected.count {
            XCTAssertEqual(expected[i], actualMapped[i])
        }
        
        XCTAssertTrue(result.isSuccess())
        XCTAssertTrue(expected.elementsEqual(actualMapped))
    }
    
    func testFailingTrace() {
        let actual = TraceArrayConsumer()
        
        let expected = [
        "FlattenParser",
        "  SequenceParser",
        "    CharacterParser[letter expected]",
        "    Failure[1:1]: letter expected",
        "  Failure[1:1]: letter expected",
        "Failure[1:1]: letter expected"
        ]

        let result = Tracer.on(TracerTest.IDENTIFIER, consumer: actual).parse("1")
        XCTAssertFalse(result.isSuccess())
        XCTAssertTrue(expected.elementsEqual(actual.events.map { "\($0)" }))
    }
}
