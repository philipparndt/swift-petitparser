//
//  RepeatingParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public enum InvalidArgumentError: Error {
    case runtimeError(String)
}

public class RepeatingParser: DelegateParser {
    public static let UNBOUNDED = -1
    
    let min: Int
    let max: Int
    
    public init(_ delegate: Parser, _ min: Int, _ max: Int) {
        self.min = min
        self.max = max
        
        super.init(delegate)

//        if (min < 0) {
//            throw InvalidArgumentError.runtimeError("Invalid min repetitions: \(getRange())")
//        }
//        if (max != RepeatingParser.UNBOUNDED && min > max) {
//            throw InvalidArgumentError.runtimeError("Invalid max repetitions: \(getRange())")
//        }
    }
    
    func getRange() -> String {
        let end = max == RepeatingParser.UNBOUNDED ? "*" : "\(max)"
        return "\(min)..\(end)"
    }
    
    public override func hasEqualProperties(_ other: Parser) -> Bool {
        if let oth = other as? RepeatingParser {
            return super.hasEqualProperties(other)
                && oth.min == min
                && oth.max == max
        }
        
        return false
    }
}

extension Parser {
    public func star() -> Parser {
        return repeated(0, RepeatingParser.UNBOUNDED)
    }
    
    public func starGreedy(_ limit: Parser) -> Parser {
        return repeatGreedy(limit, 0, RepeatingParser.UNBOUNDED)
    }

    public func starLazy(_ limit: Parser) -> Parser {
        return repeatLazy(limit, 0, RepeatingParser.UNBOUNDED)
    }
    
    public func plus() -> Parser {
        return repeated(1, RepeatingParser.UNBOUNDED)
    }
    
    public func plusGreedy(_ limit: Parser) -> Parser {
        return repeatGreedy(limit, 1, RepeatingParser.UNBOUNDED)
    }
    
    public func plusLazy(_ limit: Parser) -> Parser {
        return repeatLazy(limit, 1, RepeatingParser.UNBOUNDED)
    }
    
    public func repeated(_ min: Int, _ max: Int) -> Parser {
        return PossessiveRepeatingParser(self, min, max)
    }
    
    public func repeatGreedy(_ limit: Parser, _ min: Int, _ max: Int) -> Parser {
      return GreedyRepeatingParser(self, limit, min, max)
    }
    
    public func repeatLazy(_ limit: Parser, _ min: Int, _ max: Int) -> Parser {
      return LazyRepeatingParser(self, limit, min, max)
    }
    
    public func times(_ count: Int) -> Parser {
        return repeated(count, count)
    }
}
