//
//  Ex.swift
//  Tests
//
//  Created by Philipp Arndt on 2019-12-26.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_petitparser

class Example: XCTestCase {
    func testParseInt() {
        let id = CP.letter().seq(CP.letter().or(CP.digit()).star())
        let id1 = id.parse("yeah")
        let id2 = id.parse("f12")
        print(id1.get()!)
        print(id2.get()!)
        
        let text = "123"
        let id3 = id.parse(text)
        print(id3.message!)
        print(id3.position.utf16Offset(in: text))
        
        print(id.accept("foo"))  // true
        print(id.accept("123"))  // false
        
        let id_b = CP.letter().seq(CP.word().star()).flatten()
        print(id_b.parse("yeah").get()!)
    }
    
    func testMatchesSkipping() {
        let id = CP.letter().seq(CP.word().star()).flatten()
        let matches: [String] = id.matchesSkipping("foo 123 bar4")
        print(matches)  // ["foo", "bar4"]
    }
    
    func testParseNumber() {
        let number = CP.digit().plus().flatten().trim()
            .map { (d: String) -> Int in Int(d)! }

        print(number.parse("123").get()!) // 123
    }
}
