//
//  Numbers.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-24.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class NumbersParser {
    public class func int() -> Parser {
        return CharacterParser.digit().plus()
        .flatten().trim()
        .map { (int: String) -> Int in Int(int)! }
    }
    
    public class func double() -> Parser {
        return CharacterParser.digit().plus().seq(CharacterParser.of(".")
        .seq(CharacterParser.digit().plus()).optional())
        .flatten().trim()
        .map { (double: String) -> Double in Double(double)! }
    }
}
