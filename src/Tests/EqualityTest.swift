//
//  EqualityTest.swift
//  Tests
//
//  Created by Philipp Arndt on 2019-12-23.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_petitparser

class EqualityTest: XCTestCase {
    func verify(_ parser: Parser) {
        let copy = parser.copy()
        XCTAssertNotEqual(ObjectIdentifier(copy), ObjectIdentifier(parser))
        assertPairwiseSame(copy.getChildren(), parser.getChildren())
        XCTAssertTrue(copy.hasEqualProperties(parser))
        
        // check equality
        XCTAssertTrue(copy.isEqualTo(copy))
        XCTAssertTrue(parser.isEqualTo(copy))
        XCTAssertTrue(copy.isEqualTo(parser))
        XCTAssertTrue(parser.isEqualTo(parser))
        
        // check replacing
        var replaced: [Parser] = []
        for i in 0 ..< copy.getChildren().count {
            let source = copy.getChildren()[i]
            let target = CharacterParser.any()
            copy.replace(source, target)
            XCTAssertEqual(target, copy.getChildren()[i])
            replaced.append(target)
        }
        assertPairwiseSame(replaced, copy.getChildren())
    }
    
    func assertPairwiseSame(_ expected: [Parser], _ actual: [Parser]) {
        XCTAssertEqual(expected.count, actual.count)
        for i in 0 ..< expected.count {
             XCTAssertEqual(expected[i], actual[i])
        }
    }
        
    func testAny() {
        verify(CP.any())
    }
    
    func testAnd() {
        verify(CP.digit().and())
    }
    
    func testChar() {
        verify(CP.of("a"))
    }
    
    func testDigit() {
        verify(CP.digit())
    }
    
    func testDelegate() {
        verify(DelegateParser(CP.any()))
    }
//
//    func testContinuation() {
//        verify(CP.digit().callCC((continuation, context) -> null))
//    }

    func testEnd() {
        verify(CP.digit().end())
    }

    func testEpsilon() {
        verify(EpsilonParser())
    }

    func testFailure() {
        verify(FailureParser.withMessage("failure"))
    }

    func testFlatten1() {
        verify(CP.digit().flatten())
    }

    func testFlatten2() {
        verify(CP.digit().flatten("digit"))
    }

    func testMap() {
        verify(CP.digit().map { (any: Any) -> Any in any })
    }

    func testNot() {
        verify(CP.digit().not())
    }

    func testOptional() {
        verify(CP.digit().optional())
    }

    func testOr() {
        verify(CP.digit().or(CP.word()))
    }

    func testPlus() {
        verify(CP.digit().plus())
    }

    func testPlusGreedy() {
        verify(CP.digit().plusGreedy(CP.word()))
    }

    func testPlusLazy() {
        verify(CP.digit().plusLazy(CP.word()))
    }

    func testRepeat() {
        verify(CP.digit().repeated(2, 3))
    }

    func testRepeatGreedy() {
        verify(CP.digit().repeatGreedy(CP.word(), 2, 3))
    }

    func testRepeatLazy() {
        verify(CP.digit().repeatLazy(CP.word(), 2, 3))
    }

    func testSeq() {
        verify(CP.digit().seq(CP.word()))
    }

    func testSettable() {
        verify(CP.digit().settable())
    }

    func testStar() {
        verify(CP.digit().star())
    }

    func testStarGreedy() {
        verify(CP.digit().starGreedy(CP.word()))
    }

    func testStarLazy() {
        verify(CP.digit().starLazy(CP.word()))
    }

    func testString() {
        verify(StringParser.of("ab"))
    }

    func testStringIgnoringCase() {
        verify(StringParser.ofIgnoringCase("ab"))
    }

    func testTimes() {
        verify(CP.digit().times(2))
    }

    func testToken() {
        verify(CP.digit().token())
    }

    func testTrim() {
        verify(CP.digit()
                .trim(CP.of("a"), CP.of("b")))
    }
}
