//
//  TokenTest.swift
//  Tests
//
//  Created by Philipp Arndt on 2019-12-23.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_petitparser

class TokenTest: XCTestCase {
    let parser = CP.any()
        .map { (any: Character) -> String in String(any) }
        .token().star()
    let buffer = "1\r12\r\n123\n1234"
   
    func testBuffer() {
        let result: [Token] = parser.parse(buffer).get()!
        let expected = [buffer, buffer, buffer, buffer, buffer, buffer, buffer, buffer, buffer,
                      buffer, buffer, buffer, buffer]

        let actual = result.map { $0.buffer }
        XCTAssertTrue(expected.elementsEqual(actual))
    }

    func testInput() {
        let result: [Token] = parser.parse(buffer).get()!
        let expected = ["1", "\r", "1", "2", "\r\n", "1", "2", "3", "\n", "1", "2", "3",
        "4"]

        let actual = result.map { $0.getInput() }
        XCTAssertTrue(expected.elementsEqual(actual))
    }
    
    func testLength() {
        let result: [Token] = parser.parse(buffer).get()!
        let expected = [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
        let actual = result.map { $0.getLength() }
        
        XCTAssertTrue(expected.elementsEqual(actual))
    }

    func testStart() {
        let result: [Token] = parser.parse(buffer).get()!
        let expected = [ 0, 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13]
        let actual = result.map { $0.start.utf16Offset(in: buffer) }
        
        XCTAssertTrue(expected.elementsEqual(actual))
    }

    func testStop() {
        let result: [Token] = parser.parse(buffer).get()!
        let expected = [ 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14]
        let actual = result.map { $0.stop.utf16Offset(in: buffer) }
        
        XCTAssertTrue(expected.elementsEqual(actual))
    }

    func testValue() {
        let result: [Token] = parser.parse(buffer).get()!
        let expected = ["1", "\r", "1", "2", "\r\n", "1", "2", "3", "\n", "1", "2", "3", "4"]
        let actual: [String] = result.map { $0.value as! String }
        XCTAssertTrue(expected.elementsEqual(actual))
    }
    
    func testLine() {
        let result: [Token] = parser.parse(buffer).get()!
        let expected = [1, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3]
        
        let actual = result.map { $0.getLine() }
        XCTAssertTrue(expected.elementsEqual(actual))
    }
    
    func testColumn() {
        let result: [Token] = parser.parse(buffer).get()!
        let expected = [1, 2, 1, 2, 3, 5, 6, 7, 8, 1, 2, 3, 4]
        
        let actual = result.map { $0.getColumn() }
        XCTAssertTrue(expected.elementsEqual(actual))
    }
    
    func testHashCode() {
        let result: [Token] = parser.parse(buffer).get()!
        let uniques: Set<Int> = Set(result.map { $0.hashValue })
        
        XCTAssertEqual(result.count, uniques.count)
    }
    
    func testEquals() {
        let result: [Token] = parser.parse(buffer).get()!
        
        for i in 0 ..< result.count {
            let first = result[i]
            for j in 0 ..< result.count {
                let second = result[j]
                
                if i == j {
                    XCTAssertEqual(first, second)
                }
                else {
                    XCTAssertNotEqual(first, second)
                }
            }
            
            XCTAssertEqual(first, Token(first.buffer, first.start, first.stop, first.value))
            XCTAssertNotEqual(first, Token("", first.start, first.stop, first.value))
            XCTAssertNotEqual(first, Token(first.buffer, first.buffer.index(after: first.start), first.stop, first.value))
            XCTAssertNotEqual(first, Token(first.buffer, first.start, first.buffer.index(before: first.stop), first.value))
            XCTAssertNotEqual(first, Token(first.buffer, first.start, first.stop, first))
        }
        
    }
}
