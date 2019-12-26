//
//  GrammarDefinitionTest.swift
//  Tests
//
//  Created by Philipp Arndt on 2019-12-22.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_petitparser

class ListGrammarDefinition: GrammarDefinition {
    override init() {
        super.init()
        
        def("start", ref("list").end())
        def("list", ref("element").seq(CP.of(",").flatten()).seq(ref("list")).or(ref("element")))
        def("element", CP.digit().plus().flatten())
    }
}

class ListParserDefinition: ListGrammarDefinition {
    override init() {
        super.init()

        let function: (String) -> Int = { Int($0)! }
        action("element", function)
    }
}

class ExpressionGrammarDefinition: GrammarDefinition {
    override init() {
        super.init()
    
        def("start", ref("terms").end())
        
        def("terms", ref("addition").or(ref("factors")))
        def("addition", ref("factors").separatedBy(CP.pattern("+-").flatten().trim()))
        
        def("factors", ref("multiplication").or(ref("power")))
        def("multiplication", ref("power").separatedBy(CP.pattern("*/").flatten().trim()))
        
        def("power", ref("primary").separatedBy(CP.of("^").flatten().trim()))
        def("primary", ref("number").or(ref("parentheses")))
        
        def("number", CP.of("-").flatten().trim().optional()
            .seq(CP.digit().plus())
            .seq(CP.of(".")
                .seq(CP.digit().plus())
                .optional()))
        
        def("parentheses", CP.of("(").flatten().trim()
            .seq(ref("terms"))
            .seq(CP.of(")").flatten().trim()))
    }
}

class GrammarDefinitionTest: XCTestCase {

    func testGrammar() {
        let parser = ListGrammarDefinition().build()
        Assert.arrayEquals(["1", ",", "2"], parser.parse("1,2").get()!)
    }
    
    func testParser() {
        let parser = GrammarParser(ListGrammarDefinition(), "start")
        Assert.arrayEquals(["1", ",", "2"], parser.parse("1,2").get()!)
    }
    
    func testExpressionGrammar() {
        let parser = GrammarParser(ExpressionGrammarDefinition())
        XCTAssertTrue(parser.accept("1"))
        XCTAssertTrue(parser.accept("12"))
        XCTAssertTrue(parser.accept("1.23"))
        XCTAssertTrue(parser.accept("-12.3"))
        XCTAssertTrue(parser.accept("1 + 2"))
        XCTAssertTrue(parser.accept("1 + 2 + 3"))
        XCTAssertTrue(parser.accept("1 - 2"))
        XCTAssertTrue(parser.accept("1 - 2 - 3"))
        XCTAssertTrue(parser.accept("1 * 2"))
        XCTAssertTrue(parser.accept("1 * 2 * 3"))
        XCTAssertTrue(parser.accept("1 / 2"))
        XCTAssertTrue(parser.accept("1 / 2 / 3"))
        XCTAssertTrue(parser.accept("1 ^ 2"))
        XCTAssertTrue(parser.accept("1 ^ 2 ^ 3"))
        XCTAssertTrue(parser.accept("1 + (2 * 3)"))
        XCTAssertTrue(parser.accept("(1 + 2) * 3"))
    }
}
