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
        .flatten()
        .map { (int: String) -> Int in Int(int)! }
    }
    
    public class func int(from start: Int, to end: Int) -> Parser {
        let validator: (Context, Int) -> Result? = {
            if $1 >= start && $1 <= end {
               return nil
            }
            else {
                return $0.failure("Expected value in range \(start)..\(end)")
            }
        }
        
        return int().validate(validator)
    }
    
    public class func double() -> Parser {
        return CharacterParser.digit().plus().seq(CharacterParser.of(".")
        .seq(CharacterParser.digit().plus()).optional())
        .flatten()
        .map { (double: String) -> Double in Double(double)! }
    }
    
    public class func double(from start: Double, to end: Double) -> Parser {
        let validator: (Context, Double) -> Result? = {
            if $1 >= start && $1 <= end {
               return nil
            }
            else {
                return $0.failure("Expected value in range \(start)..\(end)")
            }
        }
        
        return double().validate(validator)
    }
}
