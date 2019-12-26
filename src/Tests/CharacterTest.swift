//
//  CharacterTest.swift
//  Tests
//
//  Created by Philipp Arndt on 2019-12-19.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

import XCTest
@testable import swift_petitparser

class CharacterTest: XCTestCase {
    let _0: Character = "0"
    let _1: Character = "1"
    let _9: Character = "9"
    let minus: Character = "-"
    let space: Character = " "
    let a: Character = "a"
    let b: Character = "b"
    let c: Character = "c"
    let d: Character = "d"
    let e: Character = "e"
    let f: Character = "f"
    let g: Character = "g"
    let h: Character = "h"
    let i: Character = "i"
    let o: Character = "o"
    let p: Character = "p"
    let r: Character = "r"
    let t: Character = "t"
    let x: Character = "x"
    let X: Character = "X"
    let y: Character = "y"
    
    func testAny() {
        let parser = CP.any()
        Assert.assertSuccess(parser, "a", a)
        Assert.assertSuccess(parser, "b", b)
        Assert.assertFailure(parser, "", "any character expected")
    }
    
    func testAnyWithMessage() {
        let parser = CP.any("wrong")
        Assert.assertSuccess(parser, "a", a)
        Assert.assertSuccess(parser, "b", b)
        Assert.assertFailure(parser, "", "wrong")
    }
    
    func testAnyOf() {
        let parser = CP.anyOf("uncopyrightable")
        Assert.assertSuccess(parser, "c", c)
        Assert.assertSuccess(parser, "g", g)
        Assert.assertSuccess(parser, "h", h)
        Assert.assertSuccess(parser, "i", i)
        Assert.assertSuccess(parser, "o", o)
        Assert.assertSuccess(parser, "p", p)
        Assert.assertSuccess(parser, "r", r)
        Assert.assertSuccess(parser, "t", t)
        Assert.assertSuccess(parser, "y", y)
        Assert.assertFailure(parser, "x", "any of 'uncopyrightable' expected")
    }
    
    func testAnyOfWithMessage() {
        let parser = CP.anyOf("uncopyrightable", "wrong")
        Assert.assertSuccess(parser, "c", c)
        Assert.assertSuccess(parser, "g", g)
        Assert.assertSuccess(parser, "h", h)
        Assert.assertSuccess(parser, "i", i)
        Assert.assertSuccess(parser, "o", o)
        Assert.assertSuccess(parser, "p", p)
        Assert.assertSuccess(parser, "r", r)
        Assert.assertSuccess(parser, "t", t)
        Assert.assertSuccess(parser, "y", y)
        Assert.assertFailure(parser, "x", "wrong")
    }
    
    func testAnyOfEmpty() {
        let parser = CP.anyOf("")
        Assert.assertFailure(parser, "a", "any of '' expected")
        Assert.assertFailure(parser, "b", "any of '' expected")
        Assert.assertFailure(parser, "", "any of '' expected")
    }
    
    func testNone() {
        let parser = CP.none()
        Assert.assertFailure(parser, "a", "no character expected")
        Assert.assertFailure(parser, "b", "no character expected")
        Assert.assertFailure(parser, "", "no character expected")
    }
    
    func testNoneWithMessage() {
        let parser = CP.none("wrong")
        Assert.assertFailure(parser, "a", "wrong")
        Assert.assertFailure(parser, "b", "wrong")
        Assert.assertFailure(parser, "", "wrong")
    }
    
    func testNoneOf() {
        let parser = CP.noneOf("uncopyrightable")
        Assert.assertSuccess(parser, "x", x)
        Assert.assertFailure(parser, "c", "none of 'uncopyrightable' expected")
        Assert.assertFailure(parser, "g", "none of 'uncopyrightable' expected")
        Assert.assertFailure(parser, "h", "none of 'uncopyrightable' expected")
        Assert.assertFailure(parser, "i", "none of 'uncopyrightable' expected")
        Assert.assertFailure(parser, "o", "none of 'uncopyrightable' expected")
        Assert.assertFailure(parser, "p", "none of 'uncopyrightable' expected")
        Assert.assertFailure(parser, "r", "none of 'uncopyrightable' expected")
        Assert.assertFailure(parser, "t", "none of 'uncopyrightable' expected")
        Assert.assertFailure(parser, "y", "none of 'uncopyrightable' expected")
    }
    
    func testNoneOfWithMessage() {
        let parser = CP.noneOf("uncopyrightable", "wrong")
        Assert.assertSuccess(parser, "x", x)
        Assert.assertFailure(parser, "c", "wrong")
        Assert.assertFailure(parser, "g", "wrong")
        Assert.assertFailure(parser, "h", "wrong")
        Assert.assertFailure(parser, "i", "wrong")
        Assert.assertFailure(parser, "o", "wrong")
        Assert.assertFailure(parser, "p", "wrong")
        Assert.assertFailure(parser, "r", "wrong")
        Assert.assertFailure(parser, "t", "wrong")
        Assert.assertFailure(parser, "y", "wrong")
    }
    
    func testNoneOfEmpty() {
        let parser = CP.noneOf("")
        Assert.assertSuccess(parser, "a", a)
        Assert.assertSuccess(parser, "b", b)
        Assert.assertFailure(parser, "", "none of '' expected")
    }
    
    func testIs() {
        let parser = CP.of("a")
        Assert.assertSuccess(parser, "a", a)
        Assert.assertFailure(parser, "b", "'a' expected")
        Assert.assertFailure(parser, "", "'a' expected")
    }
    
    func testIsWithMessage() {
        let parser = CP.of("a", "wrong")
        Assert.assertSuccess(parser, "a", a)
        Assert.assertFailure(parser, "b", "wrong")
        Assert.assertFailure(parser, "", "wrong")
    }
    
    func testDigit() {
        let parser = CP.digit()
        Assert.assertSuccess(parser, "1", _1)
        Assert.assertSuccess(parser, "9", _9)
        Assert.assertFailure(parser, "a", "digit expected")
        Assert.assertFailure(parser, "", "digit expected")
    }
    
    func testDigitWithMessage() {
        let parser = CP.digit("wrong")
        Assert.assertSuccess(parser, "1", _1)
        Assert.assertSuccess(parser, "9", _9)
        Assert.assertFailure(parser, "a", "wrong")
        Assert.assertFailure(parser, "", "wrong")
    }
    
    func testLetter() {
        let parser = CP.letter()
        Assert.assertSuccess(parser, "a", a)
        Assert.assertSuccess(parser, "X", X)
        Assert.assertFailure(parser, "0", "letter expected")
        Assert.assertFailure(parser, "", "letter expected")
    }
    
    func testLetterWithMessage() {
        let parser = CP.letter("wrong")
        Assert.assertSuccess(parser, "a", a)
        Assert.assertSuccess(parser, "X", X)
        Assert.assertFailure(parser, "0", "wrong")
        Assert.assertFailure(parser, "", "wrong")
    }
    
    func testLowerCase() {
        let parser = CP.lowerCase()
        Assert.assertSuccess(parser, "a", a)
        Assert.assertFailure(parser, "A", "lowercase letter expected")
        Assert.assertFailure(parser, "0", "lowercase letter expected")
        Assert.assertFailure(parser, "", "lowercase letter expected")
    }
    
    func testLowerCaseWithMessage() {
        let parser = CP.lowerCase("wrong")
        Assert.assertSuccess(parser, "a", a)
        Assert.assertFailure(parser, "A", "wrong")
        Assert.assertFailure(parser, "0", "wrong")
        Assert.assertFailure(parser, "", "wrong")
    }
    
    func testPatternWithSingle() {
        let parser = CP.pattern("abc")
        Assert.assertSuccess(parser, "a", a)
        Assert.assertSuccess(parser, "b", b)
        Assert.assertSuccess(parser, "c", c)
        Assert.assertFailure(parser, "d", "[abc] expected")
        Assert.assertFailure(parser, "", "[abc] expected")
    }
    
    func testPatternWithMessage() {
        let parser = CP.pattern("abc", "wrong")
        Assert.assertSuccess(parser, "a", a)
        Assert.assertFailure(parser, "d", "wrong")
        Assert.assertFailure(parser, "", "wrong")
    }
    
    func testPatternWithRange() {
        let parser = CP.pattern("a-c")
        Assert.assertSuccess(parser, "a", a)
        Assert.assertSuccess(parser, "b", b)
        Assert.assertSuccess(parser, "c", c)
        Assert.assertFailure(parser, "d", "[a-c] expected")
        Assert.assertFailure(parser, "", "[a-c] expected")
    }
    
    func testPatternWithOverlappingRange() {
        let parser = CP.pattern("b-da-c")
        Assert.assertSuccess(parser, "a", a)
        Assert.assertSuccess(parser, "b", b)
        Assert.assertSuccess(parser, "c", c)
        Assert.assertSuccess(parser, "d", d)
        Assert.assertFailure(parser, "e", "[b-da-c] expected")
        Assert.assertFailure(parser, "", "[b-da-c] expected")
    }
    
    func testPatternWithAdjacentRange() {
        let parser = CP.pattern("c-ea-c")
        Assert.assertSuccess(parser, "a", a)
        Assert.assertSuccess(parser, "b", b)
        Assert.assertSuccess(parser, "c", c)
        Assert.assertSuccess(parser, "d", d)
        Assert.assertSuccess(parser, "e", e)
        Assert.assertFailure(parser, "f", "[c-ea-c] expected")
        Assert.assertFailure(parser, "", "[c-ea-c] expected")
    }
    
    func testPatternWithPrefixRange() {
        let parser = CP.pattern("a-ea-c")
        Assert.assertSuccess(parser, "a", a)
        Assert.assertSuccess(parser, "b", b)
        Assert.assertSuccess(parser, "c", c)
        Assert.assertSuccess(parser, "d", d)
        Assert.assertSuccess(parser, "e", e)
        Assert.assertFailure(parser, "f", "[a-ea-c] expected")
        Assert.assertFailure(parser, "", "[a-ea-c] expected")
    }
    
    func testPatternWithPostfixRange() {
        let parser = CP.pattern("a-ec-e")
        Assert.assertSuccess(parser, "a", a)
        Assert.assertSuccess(parser, "b", b)
        Assert.assertSuccess(parser, "c", c)
        Assert.assertSuccess(parser, "d", d)
        Assert.assertSuccess(parser, "e", e)
        Assert.assertFailure(parser, "f", "[a-ec-e] expected")
        Assert.assertFailure(parser, "", "[a-ec-e] expected")
    }
    
    func testPatternWithRepeatedRange() {
        let parser = CP.pattern("a-ea-e")
        Assert.assertSuccess(parser, "a", a)
        Assert.assertSuccess(parser, "b", b)
        Assert.assertSuccess(parser, "c", c)
        Assert.assertSuccess(parser, "d", d)
        Assert.assertSuccess(parser, "e", e)
        Assert.assertFailure(parser, "f", "[a-ea-e] expected")
        Assert.assertFailure(parser, "", "[a-ea-e] expected")
    }
    
    func testPatternWithComposed() {
        let parser = CP.pattern("ac-df-")
        Assert.assertSuccess(parser, "a", a)
        Assert.assertSuccess(parser, "c", c)
        Assert.assertSuccess(parser, "d", d)
        Assert.assertSuccess(parser, "f", f)
        Assert.assertSuccess(parser, "-", minus)
        Assert.assertFailure(parser, "b", "[ac-df-] expected")
        Assert.assertFailure(parser, "e", "[ac-df-] expected")
        Assert.assertFailure(parser, "g", "[ac-df-] expected")
        Assert.assertFailure(parser, "", "[ac-df-] expected")
    }
    
    func testPatternWithNegatedSingle() {
        let parser = CP.pattern("^a")
        Assert.assertSuccess(parser, "b", b)
        Assert.assertFailure(parser, "a", "[^a] expected")
        Assert.assertFailure(parser, "", "[^a] expected")
    }
    
    func testPatternWithNegatedRange() {
        let parser = CP.pattern("^a-c")
        Assert.assertSuccess(parser, "d", d)
        Assert.assertFailure(parser, "a", "[^a-c] expected")
        Assert.assertFailure(parser, "b", "[^a-c] expected")
        Assert.assertFailure(parser, "c", "[^a-c] expected")
        Assert.assertFailure(parser, "", "[^a-c] expected")
    }
    
    func testRange() {
        let parser = CP.range("e", "o")
        Assert.assertFailure(parser, "d", "e..o expected")
        Assert.assertSuccess(parser, "e", e)
        Assert.assertSuccess(parser, "i", i)
        Assert.assertSuccess(parser, "o", o)
        Assert.assertFailure(parser, "p", "e..o expected")
        Assert.assertFailure(parser, "", "e..o expected")
    }
    
    func testRangeWithMessage() {
        let parser = CP.range("e", "o", "wrong")
        Assert.assertFailure(parser, "d", "wrong")
        Assert.assertSuccess(parser, "e", e)
        Assert.assertSuccess(parser, "i", i)
        Assert.assertSuccess(parser, "o", o)
        Assert.assertFailure(parser, "p", "wrong")
        Assert.assertFailure(parser, "", "wrong")
    }
    
    func testUpperCase() {
        let parser = CP.upperCase()
        Assert.assertSuccess(parser, "X", X)
        Assert.assertFailure(parser, "x", "uppercase letter expected")
        Assert.assertFailure(parser, "0", "uppercase letter expected")
        Assert.assertFailure(parser, "", "uppercase letter expected")
    }
    
    func testUpperCaseWithMessage() {
        let parser = CP.upperCase("wrong")
        Assert.assertSuccess(parser, "X", X)
        Assert.assertFailure(parser, "x", "wrong")
        Assert.assertFailure(parser, "0", "wrong")
        Assert.assertFailure(parser, "", "wrong")
    }
    
    func testWhitespace() {
        let parser = CP.whitespace()
        Assert.assertSuccess(parser, " ", space)
        Assert.assertFailure(parser, "z", "whitespace expected")
        Assert.assertFailure(parser, "-", "whitespace expected")
        Assert.assertFailure(parser, "", "whitespace expected")
    }
    
    func testWhitespaceWithMessage() {
        let parser = CP.whitespace("wrong")
        Assert.assertSuccess(parser, " ", space)
        Assert.assertFailure(parser, "z", "wrong")
        Assert.assertFailure(parser, "-", "wrong")
        Assert.assertFailure(parser, "", "wrong")
    }
    
    func testWord() {
        let parser = CP.word()
        Assert.assertSuccess(parser, "a", a)
        Assert.assertSuccess(parser, "0", _0)
        Assert.assertFailure(parser, "-", "letter or digit expected")
        Assert.assertFailure(parser, "", "letter or digit expected")
    }
    
    func testWordWithMessage() {
        let parser = CP.word("wrong")
        Assert.assertSuccess(parser, "a", a)
        Assert.assertSuccess(parser, "0", _0)
        Assert.assertFailure(parser, "-", "wrong")
        Assert.assertFailure(parser, "", "wrong")
    }
}
