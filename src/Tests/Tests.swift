//
//  Tests.swift
//  Tests
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import XCTest
@testable import swift_petitparser

class Tests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFailure() {
        let buffer = "test"
        let failure = Failure(buffer, buffer.startIndex, "some error")
        XCTAssertEqual(buffer, failure.buffer)
        XCTAssertTrue(failure.get() == nil)
    }

    func testDelimitedBy() {
        let parser = CP.of("a").delimitedBy(CP.of("b"))
        
        assertSuccess(parser, "a", ["a"])
        assertSuccess(parser, "ab", ["a", "b"])
        assertSuccess(parser, "aba", ["a", "b", "a"])
        assertSuccess(parser, "abab", ["a", "b", "a", "b"])
        assertSuccess(parser, "ababa", ["a", "b", "a", "b", "a"])
        assertSuccess(parser, "ababab", ["a", "b", "a", "b", "a", "b"])
    }
        
    func assertSuccess(_ parser: Parser, _ text: String, _ array: [Character]) {
        let result = parser.parse(text)
        XCTAssertEqual(result.isSuccess(), true)
        let resultValues: [Character] = parser.parse(text).get()!
        XCTAssertEqual(array.elementsEqual(resultValues), true)
    }

    func testFlatten() {
        let parser = CP.digit().plus().flatten().end()
        XCTAssertEqual("12", parser.parse("12").get()!)

        XCTAssertEqual(parser.parse("1").isSuccess(), true)
        XCTAssertEqual(parser.parse("12").isSuccess(), true)
        XCTAssertEqual(parser.parse("123").isSuccess(), true)
    }

    func testTrim() {
        let parser = CP.digit().plus().flatten().trim().end()
        let result: String? = parser.parse("  12  ").get()
        XCTAssertEqual("12", result!)

        XCTAssertEqual(parser.parse("1").isSuccess(), true)
        XCTAssertEqual(parser.parse("12").isSuccess(), true)
        XCTAssertEqual(parser.parse("123").isSuccess(), true)
    }

    func testParseNumber() {
        let parser = CP.digit().seq(CP.digit().optional()).end()
        XCTAssertEqual(parser.parse("1").isSuccess(), true)
        XCTAssertEqual(parser.parse("12").isSuccess(), true)
        XCTAssertEqual(parser.parse("123").isSuccess(), false)
    }
    
    func testParseNumberUnbounded() {
        let parser = CP.digit().star().end()
        XCTAssertEqual(parser.parse("1").isSuccess(), true)
        XCTAssertEqual(parser.parse("12").isSuccess(), true)
        XCTAssertEqual(parser.parse("123").isSuccess(), true)
        XCTAssertEqual(parser.parse("123a").isSuccess(), false)
    }
    
    func testParseNumber_Failing() {
        let parser = CP.digit()
            .seq(CP.digit().optional())
            .end()
        let result = parser.parse("a")
        XCTAssertEqual(result.isSuccess(), false)
    }

}
