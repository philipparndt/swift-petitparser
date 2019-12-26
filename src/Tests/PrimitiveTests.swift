//
//  PrimitiveTests.swift
//  Tests
//
//  Created by Philipp Arndt on 2019-12-19.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

import XCTest
@testable import swift_petitparser

class PrimitiveTests: XCTestCase {
    func testEpsilon() {
        let parser = EpsilonParser()
        Assert.assertSuccess(parser, "", NSNull())
        Assert.assertSuccess(parser, "a", NSNull(), "a".startIndex)
    }
    
    func testFailure() {
        let parser = FailureParser.withMessage("wrong")
        Assert.assertFailure(parser, "", "wrong")
        Assert.assertFailure(parser, "a", "wrong")
    }
    
    func testString() {
        let parser = StringParser.of("foo").end()
        Assert.assertSuccess(parser, "foo", "foo")
        Assert.assertFailure(parser, "", "foo expected")
        Assert.assertFailure(parser, "f", "foo expected")
        Assert.assertFailure(parser, "fo", "foo expected")
        Assert.assertFailure(parser, "Foo", "foo expected")
        Assert.assertFailure(parser, "foobar", 3, "end of input expected")
    }
    
    func testStringWithMessage() {
        let parser = StringParser.of("foo", "wrong").end()
        Assert.assertSuccess(parser, "foo", "foo")
        Assert.assertFailure(parser, "", "wrong")
        Assert.assertFailure(parser, "f", "wrong")
        Assert.assertFailure(parser, "fo", "wrong")
        Assert.assertFailure(parser, "Foo", "wrong")
    }
    
    func testStringIgnoreCase() {
        let parser = StringParser.ofIgnoringCase("foo").end()
        Assert.assertSuccess(parser, "foo", "foo")
        Assert.assertSuccess(parser, "FOO", "FOO")
        Assert.assertSuccess(parser, "fOo", "fOo")
        Assert.assertFailure(parser, "", "foo expected")
        Assert.assertFailure(parser, "f", "foo expected")
        Assert.assertFailure(parser, "Fo", "foo expected")
    }

    func testStringIgnoreCaseWithMessage() {
        let parser = StringParser.ofIgnoringCase("foo", "wrong").end()
        Assert.assertSuccess(parser, "foo", "foo")
        Assert.assertSuccess(parser, "FOO", "FOO")
        Assert.assertSuccess(parser, "fOo", "fOo")
        Assert.assertFailure(parser, "", "wrong")
        Assert.assertFailure(parser, "f", "wrong")
        Assert.assertFailure(parser, "Fo", "wrong")
    }

}
