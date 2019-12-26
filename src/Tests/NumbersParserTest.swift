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
    
    func testParseDouble() {
        XCTAssertEqual(NumbersParser.double().parse("0").get()!, Double(0))
        XCTAssertEqual(NumbersParser.double().parse("0.1").get()!, Double(0.1))
        XCTAssertEqual(NumbersParser.double().parse("1").get()!, Double(1))
        XCTAssertEqual(NumbersParser.double().parse("10").get()!, Double(10))
        XCTAssertEqual(NumbersParser.double().parse("10000").get()!, Double(10000))
        XCTAssertEqual(NumbersParser.double().parse("3.14159265").get()!, Double(3.14159265))
    }
}
