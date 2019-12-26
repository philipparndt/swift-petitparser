//
//  Assert.swift
//  Tests
//
//  Created by Philipp Arndt on 2019-12-19.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_petitparser

// swiftlint:disable type_name
typealias CP = CharacterParser
typealias SP = StringParser

public class Assert {
    public static let NULL: String? = nil
    public static let EMPTY: [Character] = []
    
    public class func assertSuccess<T: Equatable>(_ parser: Parser, _ input: String, _ expected: T?) {
        assertSuccess(parser, input, expected, input.endIndex)
    }
    
    public class func assertSuccess<T: Equatable>(_ parser: Parser, _ input: String, _ expected: T?, _ position: Int) {
        let positionIdx = input.index(input.startIndex, offsetBy: position)
        assertSuccess(parser, input, expected, positionIdx)
    }
    
    public class func assertSuccess<T: Equatable>(_ parser: Parser, _ input: String, _ expected: T?, _ position: String.Index) {
        let result = parser.parse(input)
        XCTAssertTrue(result.isSuccess(), "Expected parse success")
        XCTAssertFalse(result.isFailure(), "Expected parse success")

        if expected == nil {
            XCTAssertTrue(result.get() == nil, "Expected result to be nil")
        }
        else {
            let resultValue: T = result.get()!
            XCTAssertEqual(resultValue, expected, "Result")
        }
        
        XCTAssertEqual(result.position, position, "Position")
        
        let parsePosition = parser.fastParseOn(input, input.startIndex)
        XCTAssertEqual(parsePosition!, position, "Fast parse")
        XCTAssertTrue(parser.accept(input), "Accept")
    }
    
    public class func assertFailure(_ parser: Parser, _ input: String) {
        assertFailure(parser, input, 0, nil)
    }
    
    public class func assertFailure(_ parser: Parser, _ input: String, _ position: Int) {
        assertFailure(parser, input, position, nil)
    }
    
    public class func assertFailure(_ parser: Parser, _ input: String, _ message: String?) {
        assertFailure(parser, input, 0, message)
    }
    
    public class func assertFailure(_ parser: Parser, _ input: String, _ position: Int, _ message: String?) {
         let positionIdx = input.index(input.startIndex, offsetBy: position)
        assertFailure(parser, input, positionIdx, message)
    }
    
    public class func assertFailure(_ parser: Parser, _ input: String, _ position: String.Index, _ message: String?) {
        let result = parser.parse(input)
//        XCTAssertTrue(result.message != nil)
        XCTAssertFalse(result.isSuccess())
        XCTAssertTrue(result.isFailure())
        
        if message != nil {
            XCTAssertEqual(result.message!, message)
        }
        XCTAssertEqual(result.position, position)
    }
    
    public class func assertSuccess(_ parser: Parser, _ text: String, _ array: [Character]) {
        let result = parser.parse(text)
        XCTAssertEqual(result.isSuccess(), true)
        let resultValues: [Character] = parser.parse(text).get()!
        XCTAssertTrue(array.elementsEqual(resultValues))
    }
    
    public class func arrayEquals(_ a: [String], _ b: [String]) {
        XCTAssertEqual(a.elementsEqual(b), true)
    }
}
