//
//  ExamplesTest.swift
//  Tests
//
//  Created by Philipp Arndt on 2019-12-20.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_petitparser

class ExampleTypes {
    static let identifier = (CP.letter() + CP.word()<*>).flatten()

	static let FRACTION = CP.of(".") + CP.digit()<+>

    static let NUMBER = (CP.of("-").optional()
        + CP.digit()<+> + FRACTION.optional())
        .flatten()

    static let STRING = (CP.of("\"")
        + CP.any().starLazy(CP.of("\""))
        + CP.of("\""))
        .flatten()
        
    static let RETURN = (SP.of("return")
        + CP.whitespace()<+>.flatten()
        + (identifier | NUMBER | STRING))
        .pick(-1)
    
    static let JAVADOC = (SP.of("/**")
        + CP.any().starLazy(SP.of("*/"))
        + SP.of("*/"))
        .flatten()

    static let DOUBLE = (CP.digit()<+> + FRACTION.optional())
        .flatten().trim()
        .map { (d: String) -> Double in Double(d)! }
}

// swiftlint:disable type_name
typealias T = ExampleTypes

class ExamplesTests: XCTestCase {
	
    func testIdentifierSuccess() {
        Assert.assertSuccess(T.identifier, "a", "a")
        Assert.assertSuccess(T.identifier, "a1", "a1")
        Assert.assertSuccess(T.identifier, "a12", "a12")
        Assert.assertSuccess(T.identifier, "ab", "ab")
        Assert.assertSuccess(T.identifier, "a1b", "a1b")
    }
    
    func testIdentifierIncomplete() {
        Assert.assertSuccess(T.identifier, "a_", "a", 1)
        Assert.assertSuccess(T.identifier, "a1-", "a1", 2)
        Assert.assertSuccess(T.identifier, "a12+", "a12", 3)
        Assert.assertSuccess(T.identifier, "ab ", "ab", 2)
    }
    
    func testIdentifierFailure() {
        Assert.assertFailure(T.identifier, "", "letter expected")
        Assert.assertFailure(T.identifier, "1", "letter expected")
        Assert.assertFailure(T.identifier, "1a", "letter expected")
    }
    
    func testNumberPositiveSuccess() {
        Assert.assertSuccess(T.NUMBER, "1", "1")
        Assert.assertSuccess(T.NUMBER, "12", "12")
        Assert.assertSuccess(T.NUMBER, "12.3", "12.3")
        Assert.assertSuccess(T.NUMBER, "12.34", "12.34")
    }
    
    func testNumberNegativeSuccess() {
        Assert.assertSuccess(T.NUMBER, "-1", "-1")
        Assert.assertSuccess(T.NUMBER, "-12", "-12")
        Assert.assertSuccess(T.NUMBER, "-12.3", "-12.3")
        Assert.assertSuccess(T.NUMBER, "-12.34", "-12.34")
    }
    
    func testNumberIncomplete() {
        Assert.assertSuccess(T.NUMBER, "1..", "1", 1)
        Assert.assertSuccess(T.NUMBER, "12-", "12", 2)
        Assert.assertSuccess(T.NUMBER, "12.3.", "12.3", 4)
        Assert.assertSuccess(T.NUMBER, "12.34.", "12.34", 5)
    }
    
    func testNumberFailure() {
        Assert.assertFailure(T.NUMBER, "", "digit expected")
        Assert.assertFailure(T.NUMBER, "-", 1, "digit expected")
        Assert.assertFailure(T.NUMBER, "-x", 1, "digit expected")
        Assert.assertFailure(T.NUMBER, ".", "digit expected")
        Assert.assertFailure(T.NUMBER, ".1", "digit expected")
    }
    
    func testStringSuccess() {
        Assert.assertSuccess(T.STRING, "\"\"", "\"\"")
        Assert.assertSuccess(T.STRING, "\"a\"", "\"a\"")
        Assert.assertSuccess(T.STRING, "\"ab\"", "\"ab\"")
        Assert.assertSuccess(T.STRING, "\"abc\"", "\"abc\"")
    }
    
    func testStringIncomplete() {
        Assert.assertSuccess(T.STRING, "\"\"x", "\"\"", 2)
        Assert.assertSuccess(T.STRING, "\"a\"x", "\"a\"", 3)
        Assert.assertSuccess(T.STRING, "\"ab\"x", "\"ab\"", 4)
        Assert.assertSuccess(T.STRING, "\"abc\"x", "\"abc\"", 5)
    }
    
    func testStringFailure() {
        Assert.assertFailure(T.STRING, "\"", 1, "'\"' expected")
        Assert.assertFailure(T.STRING, "\"a", 2, "'\"' expected")
        Assert.assertFailure(T.STRING, "\"ab", 3, "'\"' expected")
        Assert.assertFailure(T.STRING, "a\"", "'\"' expected")
        Assert.assertFailure(T.STRING, "ab\"", "'\"' expected")
    }
    
    func testReturnSuccess() {
        Assert.assertSuccess(T.RETURN, "return f", "f")
        Assert.assertSuccess(T.RETURN, "return  f", "f")
        Assert.assertSuccess(T.RETURN, "return foo", "foo")
        Assert.assertSuccess(T.RETURN, "return    foo", "foo")
        Assert.assertSuccess(T.RETURN, "return 1", "1")
        Assert.assertSuccess(T.RETURN, "return  1", "1")
        Assert.assertSuccess(T.RETURN, "return -2.3", "-2.3")
        Assert.assertSuccess(T.RETURN, "return    -2.3", "-2.3")
        Assert.assertSuccess(T.RETURN, "return \"a\"", "\"a\"")
        Assert.assertSuccess(T.RETURN, "return  \"a\"", "\"a\"")
    }
    
    func testReturnFailure() {
        Assert.assertFailure(T.RETURN, "retur f", 0, "return expected")
        Assert.assertFailure(T.RETURN, "return1", 6, "whitespace expected")
        Assert.assertFailure(T.RETURN, "return  $", 8, "'\"' expected")
    }
    
    func testJavaDoc() {
        Assert.assertSuccess(T.JAVADOC, "/** foo */", "/** foo */")
        Assert.assertSuccess(T.JAVADOC, "/** * * */", "/** * * */")
    }
    
    func testExpression() {
        let term = SettableParser.undefined()
        let prod = SettableParser.undefined()
        let prim = SettableParser.undefined()

        term.set(prod.seq(CP.of("+").trim()).seq(term)
            .map { (nums: [Any]) -> Int in (nums[0] as! Int) + (nums[2] as! Int) }
            .or(prod))

        prod.set(prim.seq(CP.of("*").trim()).seq(prod)
            .map { (nums: [Any]) -> Int in (nums[0] as! Int) * (nums[2] as! Int) }
            .or(prim))

        prim.set((CP.of("(").trim().seq(term).seq(CP.of(")").trim()))
            .map { (nums: [Any]) -> Int in nums[1] as! Int }
            .or(NumbersParser.int()))

        let start = term.end()
        Assert.assertSuccess(start, "1 + 1", 2)
        Assert.assertSuccess(start, "1 + 2 * 3", 7)
        Assert.assertSuccess(start, "(1 + 2) * 3", 9)
    }
    
    func testExpressionBuilderWithSettableExample() {
        let recursion = SettableParser.undefined()
        
        let bracket = CP.of("(")
            .seq(recursion)
            .seq(CP.of(")"))
            .map { (nums: [Any]) -> Double in nums[1] as! Double }

        let builder = ExpressionBuilder()
        builder.group()
            .primitive(bracket.or(T.DOUBLE))
        
        initOps(builder)
        
        recursion.set(builder.build())
        let parser = recursion.end()
        assertCalculatorExample(parser)
    }
    
    func testExpressionBuilderWithWrapperExample() {
        let builder = ExpressionBuilder()
        builder.group()
            .primitive(NumbersParser.double())
            .wrapper(CP.of("(").trim(), CP.of(")").trim(), { (nums: [Any]) -> Any in nums[1] })
        
        initOps(builder)

        let parser = builder.build().end()
        assertCalculatorExample(parser)
    }
    
    private func initOps(_ builder: ExpressionBuilder) {
       // negation is a prefix operator
       builder.group()
        .prefix(CP.of("-").trim(), { (nums: [Any]) -> Double in
            -(nums[1] as! Double)
        })

       // power is right-associative
       builder.group()
         .right(CP.of("^").trim(), { (nums: [Any]) -> Double in
             pow((nums[0] as! Double), (nums[2] as! Double))
         })

       // multiplication and addition are left-associative
       builder.group()
         .left(CP.of("*").trim(), { (nums: [Any]) -> Double in
             (nums[0] as! Double) * (nums[2] as! Double)
         })
         .left(CP.of("/").trim(), { (nums: [Any]) -> Double in
             (nums[0] as! Double) / (nums[2] as! Double)
         })
        
       builder.group()
         .left(CP.of("+").trim(), { (nums: [Any]) -> Double in
             (nums[0] as! Double) + (nums[2] as! Double)
         })
         .left(CP.of("-").trim(), { (nums: [Any]) -> Double in
             (nums[0] as! Double) - (nums[2] as! Double)
         })
     }

    func assertCalculatorExample(_ parser: Parser) {
        let intCalculator = parser.map { (value: Double) -> Int in
            Int(value)
        }
        
        Assert.assertSuccess(intCalculator, "9 - 4 - 2", 3)
        Assert.assertSuccess(intCalculator, "9 - (4 - 2)", 7)
        Assert.assertSuccess(intCalculator, "-8", -8)
        Assert.assertSuccess(intCalculator, "1+2*3", 7)
        Assert.assertSuccess(intCalculator, "1*2+3", 5)
        Assert.assertSuccess(intCalculator, "8/4/2", 1)
        Assert.assertSuccess(intCalculator, "2^2^3", 256)
     }

    func testIPAddress() {
        let ip = (NumbersParser.int(from: 0, to: 255)
			+ (CP.of(".") + NumbersParser.int(from: 0, to: 255)).times(3))
			.flatten().trim()
        
        Assert.assertSuccess(ip, "10.0.0.1", "10.0.0.1")
        Assert.assertSuccess(ip, " 10.0.0.1", "10.0.0.1")
    }

    func testHostName() {
		let host = (CP.word() | CP.of("."))<+>.flatten().trim()
        
        Assert.assertSuccess(host, " some.example.com ", "some.example.com")
    }
    
    func testIPAddressOrHostName() {
        let ip = (NumbersParser.int(from: 0, to: 255)
			+ (CP.of(".") + NumbersParser.int(from: 0, to: 255)).times(3))
        
        let host = (CP.word() | CP.of("."))<+>
        let parser = (ip | host).flatten().trim()
        Assert.assertSuccess(parser, "10.0.0.1", "10.0.0.1")
        Assert.assertSuccess(parser, " 10.0.0.1", "10.0.0.1")
        Assert.assertSuccess(parser, " some.example.com ", "some.example.com")
    }
	
	func testHostname() {
		XCTAssertEqual(validateHostname(name: "pisvr"), "pisvr")
	}
	
	func testHostnameNonAscii() {
		XCTAssertNil(validateHostname(name: "pisvr💖"))
	}
	
	private func validateHostname(name hostname: String) -> String? {
		let ip = NumbersParser.int(from: 0, to: 255)
			.seq(CharacterParser.of(".").seq(NumbersParser.int(from: 0, to: 255)).times(3))
		
		let host = CharacterParser.pattern("a-zA-Z0-9./-").plus()
		let parser = ip.or(host).flatten().trim().end()
		return parser.parse(hostname).get()
	}

}
