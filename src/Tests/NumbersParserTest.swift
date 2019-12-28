//
//  NumbersTest.swift
//  Tests
//
//  Created by Philipp Arndt on 2019-12-24.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_petitparser

class NumbersTest: XCTestCase {
    func testParseInt() {
        XCTAssertEqual(NumbersParser.int().parse("0").get()!, 0)
        XCTAssertEqual(NumbersParser.int().parse("1").get()!, 1)
        XCTAssertEqual(NumbersParser.int().parse("10").get()!, 10)
        XCTAssertEqual(NumbersParser.int().parse("10000").get()!, 10000)
    }
    
    func testParserIntInRange() {
        let parser = NumbersParser.int(from: 10, to: 20).end()
        
        XCTAssertEqual(parser.parse("10").get()!, 10)
        XCTAssertEqual(parser.parse("15").get()!, 15)
        XCTAssertEqual(parser.parse("20").get()!, 20)
        
        XCTAssertTrue(parser.parse("21").isFailure())
        XCTAssertEqual(parser.parse("21").message!, "Expected value in range 10..20")
        XCTAssertTrue(parser.parse("9").isFailure())
    }
    
    func testParseDouble() {
        XCTAssertEqual(NumbersParser.double().parse("0").get()!, Double(0))
        XCTAssertEqual(NumbersParser.double().parse("0.1").get()!, Double(0.1))
        XCTAssertEqual(NumbersParser.double().parse("1").get()!, Double(1))
        XCTAssertEqual(NumbersParser.double().parse("10").get()!, Double(10))
        XCTAssertEqual(NumbersParser.double().parse("10000").get()!, Double(10000))
        XCTAssertEqual(NumbersParser.double().parse("3.14159265").get()!, Double(3.14159265))
    }

    func testParserDoubleInRange() {
        let parser = NumbersParser.double(from: 1.1, to: 1.2).end()
        
        XCTAssertEqual(parser.parse("1.1").get()!, 1.1)
        XCTAssertEqual(parser.parse("1.12").get()!, 1.12)
        XCTAssertEqual(parser.parse("1.2").get()!, 1.2)
        
        XCTAssertTrue(parser.parse("1").isFailure())
        XCTAssertEqual(parser.parse("1").message!, "Expected value in range 1.1..1.2")
        XCTAssertTrue(parser.parse("1.21").isFailure())
    }

}
