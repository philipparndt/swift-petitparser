//
//  ExpressionBuilderTest.swift
//  Tests
//
//  Created by Philipp Arndt on 2019-12-24.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_petitparser

class ExpressionBuilderTest: XCTestCase {
    
    var parser: Parser = CP.any()
    var evaluator: Parser = CP.any()
    
    override func setUp() {
        setUpParser()
        setUpEvaluator()
    }

    fileprivate func setUpParser() {
        let builder = ExpressionBuilder()
        builder.group()
            .primitive(CP.digit().plus().seq(CP.of(".")
                .seq(CP.digit().plus()).optional())
                .flatten()
                .trim())
            .wrapper(CP.of("(").trim(), CP.of(")").trim())
        builder.group()
            .prefix(CP.of("-").trim())
        builder.group()
            .postfix(SP.of("++").trim())
            .postfix(SP.of("--").trim())
        builder.group()
            .right(CP.of("^").trim())
        builder.group()
            .left(CP.of("*").trim())
            .left(CP.of("/").trim())
        builder.group()
            .left(CP.of("+").trim())
            .left(CP.of("-").trim())
        parser = builder.build().end()
    }
    
    fileprivate func setUpEvaluator() {
      let builder = ExpressionBuilder()
      builder.group()
        .primitive(NumbersParser.double())
        .wrapper(
          CP.of("(").trim(),
          CP.of(")").trim(), { (nums: [Any]) -> Any in nums[1] })
      builder.group()
          .prefix(CP.of("-").trim(), { (nums: [AnyObject]) -> Double in
              -(nums[1] as! Double)
          })
      builder.group()
        .postfix(SP.of("++").trim(), { (nums: [AnyObject]) -> Double in
            (nums[0] as! Double + 1)
        })
        .postfix(SP.of("--").trim(), { (nums: [AnyObject]) -> Double in
            (nums[0] as! Double - 1)
        })
      builder.group()
          .right(CP.of("^").trim(), { (nums: [AnyObject]) -> Double in
              pow((nums[0] as! Double), (nums[2] as! Double))
          })
      builder.group()
          .left(CP.of("*").trim(), { (nums: [AnyObject]) -> Double in
              (nums[0] as! Double) * (nums[2] as! Double)
          })
          .left(CP.of("/").trim(), { (nums: [AnyObject]) -> Double in
              (nums[0] as! Double) / (nums[2] as! Double)
          })
      builder.group()
          .left(CP.of("+").trim(), { (nums: [AnyObject]) -> Double in
              (nums[0] as! Double) + (nums[2] as! Double)
          })
          .left(CP.of("-").trim(), { (nums: [AnyObject]) -> Double in
              (nums[0] as! Double) - (nums[2] as! Double)
          })
      evaluator = builder.build().end()
    }
    
    func assertParse<T: Equatable>(_ input: String, _ expected: T) {
        let actual: T = parser.parse(input).get()!
        XCTAssertEqual(actual, expected)
    }
    
    func assertEvaluation<T: Equatable>(_ input: String, _ expected: T) {
        let actual: T = evaluator.parse(input).get()!
        XCTAssertEqual(actual, expected)
    }
    
    func testParseNumber() {
        assertParse("0", "0")
        assertParse("1.2", "1.2")
        assertParse("34.78", "34.78")
    }
    
    func testEvaluateNumber() {
        assertEvaluation("0", 0.0)
        assertEvaluation("0.0", 0.0)
        assertEvaluation("1", 1.0)
        assertEvaluation("1.2", 1.2)
        assertEvaluation("34", 34.0)
        assertEvaluation("34.7", 34.7)
        assertEvaluation("56.78", 56.78)
    }
//    
//    func testParseNegativeNumber() {
//        assertParse("-1", ["-", "1"])
//        assertParse("-1.2", ["-", "1.2"])
//    }
    
    func testEvaluateAdd() {
        assertEvaluation("1 + 2", 3.0)
        assertEvaluation("2 + 1", 3.0)
        assertEvaluation("1 + 2.3", 3.3)
        assertEvaluation("2.3 + 1", 3.3)
        assertEvaluation("1 + -2", -1.0)
        assertEvaluation("-2 + 1", -1.0)
    }
    
    func testEvaluateAddMany() {
        assertEvaluation("1", 1.0)
        assertEvaluation("1 + 2", 3.0)
        assertEvaluation("1 + 2 + 3", 6.0)
        assertEvaluation("1 + 2 + 3 + 4", 10.0)
        assertEvaluation("1 + 2 + 3 + 4 + 5", 15.0)
    }

    func testEvaluateSub() {
        assertEvaluation("1 - 2", -1.0)
        assertEvaluation("1.2 - 1.2", 0.0)
        assertEvaluation("1 - -2", 3.0)
        assertEvaluation("-1 - -2", 1.0)
    }
    
    func testEvaluateSubMany() {
        assertEvaluation("1", 1.0)
        assertEvaluation("1 - 2", -1.0)
        assertEvaluation("1 - 2 - 3", -4.0)
        assertEvaluation("1 - 2 - 3 - 4", -8.0)
        assertEvaluation("1 - 2 - 3 - 4 - 5", -13.0)
    }
    
    func testEvaluateMul() {
        assertEvaluation("2 * 3", 6.0)
        assertEvaluation("2 * -4", -8.0)
    }
    
    func testEvaluateMulMany() {
        assertEvaluation("1 * 2", 2.0)
        assertEvaluation("1 * 2 * 3", 6.0)
        assertEvaluation("1 * 2 * 3 * 4", 24.0)
        assertEvaluation("1 * 2 * 3 * 4 * 5", 120.0)
    }
    
    func testEvaluateDiv() {
        assertEvaluation("12 / 3", 4.0)
        assertEvaluation("-16 / -4", 4.0)
    }
    
    func testEvaluateDivMany() {
        assertEvaluation("100 / 2", 50.0)
        assertEvaluation("100 / 2 / 2", 25.0)
        assertEvaluation("100 / 2 / 2 / 5", 5.0)
        assertEvaluation("100 / 2 / 2 / 5 / 5", 1.0)
    }
    
    func testEvaluatePow() {
        assertEvaluation("2 ^ 3", 8.0)
        assertEvaluation("-2 ^ 3", -8.0)
        assertEvaluation("-2 ^ -3", -0.125)
    }

    func testEvaluatePowMany() {
        assertEvaluation("4 ^ 3", 64.0)
        assertEvaluation("4 ^ 3 ^ 2", 262144.0)
        assertEvaluation("4 ^ 3 ^ 2 ^ 1", 262144.0)
        assertEvaluation("4 ^ 3 ^ 2 ^ 1 ^ 0", 262144.0)
    }
    
    func testEvaluateParenthesis() {
        assertEvaluation("(1)", 1.0)
        assertEvaluation("(1 + 2)", 3.0)
        assertEvaluation("((1))", 1.0)
        assertEvaluation("((1 + 2))", 3.0)
        assertEvaluation("2 * (3 + 4)", 14.0)
        assertEvaluation("(2 + 3) * 4", 20.0)
        assertEvaluation("6 / (2 + 4)", 1.0)
        assertEvaluation("(2 + 6) / 2", 4.0)
    }

    func testEvaluatePriority() {
        assertEvaluation("2 * 3 + 4", 10.0)
        assertEvaluation("2 + 3 * 4", 14.0)
        assertEvaluation("6 / 3 + 4", 6.0)
        assertEvaluation("2 + 6 / 2", 5.0)
    }
    
    func testEvaluatePostfixAdd() {
        assertEvaluation("0++", 1.0)
        assertEvaluation("0++++", 2.0)
        assertEvaluation("0++++++", 3.0)
        assertEvaluation("0+++1", 2.0)
        assertEvaluation("0+++++1", 3.0)
        assertEvaluation("0+++++++1", 4.0)
    }

    func testEvaluatePostfixSub() {
        assertEvaluation("1--", 0.0)
        assertEvaluation("2----", 0.0)
        assertEvaluation("3------", 0.0)
        assertEvaluation("2---1", 0.0)
        assertEvaluation("3-----1", 0.0)
        assertEvaluation("4-------1", 0.0)
    }
    
    func testEvaluatePrefixNegate() {
        assertEvaluation("1", 1.0)
        assertEvaluation("-1", -1.0)
        assertEvaluation("--1", 1.0)
        assertEvaluation("---1", -1.0)
    }
}
