//
//  TrimmingParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-19.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class TrimmingParser: DelegateParser {
    var left: Parser
    var right: Parser
    
    public init(_ delegate: Parser, _ left: Parser, _ right: Parser) {
        self.left = left
        self.right = right
        super.init(delegate)
    }
    
    public override func parseOn(_ context: Context) -> Result {
        var current = context
        let buffer = current.buffer
        
        // Trim the left part:
        let before = consume(left, buffer, current.position)
        if before != context.position {
            current = Context(buffer, before)
        }

        // Consume the delegate:
        let result = delegate.parseOn(current)
        if result.isFailure() {
          return result
        }

        // Trim the right part:
        let after = consume(right, buffer, result.position)
        return after == result.position ? result :
            result.success(result.get()!, after)
    }
    
    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        let result = delegate.fastParseOn(buffer, consume(left, buffer, position))
        return result == nil ? result : consume(right, buffer, result!)
    }
    
    func consume(_ parser: Parser, _ buffer: String, _ position: String.Index) -> String.Index {
        var current = position
        while true {
            let result = parser.fastParseOn(buffer, current)
            if result == nil {
                return current
            }
            current = result!
        }
    }
    
    public override func replace(_ source: Parser, _ target: Parser) {
        super.replace(source, target)
        
        if left === source {
            left = target
        }
        
        if right === source {
            right = target
        }
    }
    
    public override func getChildren() -> [Parser] {
        return [delegate, left, right]
    }
    
    public override func copy() -> Parser {
        return TrimmingParser(delegate, left, right)
    }
}

extension Parser {
    public func trim() -> Parser {
        return trim(CharacterParser.whitespace())
    }
    
    public func trim(_ both: Parser) -> Parser {
      return trim(both, both)
    }
    
    public func trim(_ before: Parser, _ after: Parser) -> Parser {
      return TrimmingParser(self, before, after)
    }
}
