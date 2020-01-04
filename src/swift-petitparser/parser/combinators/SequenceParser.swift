//
//  SequenceParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class SequenceParser: ListParser {

    public override init(_ parsers: [Parser]) {
        super.init(parsers)
    }
    
    public override init(_ parsers: Parser...) {
        super.init(parsers)
    }
    
    public override func parseOn(_ context: Context) -> Result {
        var current = context
        
        var elements: [Any] = []
        for parser in parsers {
            let result = parser.parseOn(current)
            if result.isFailure() {
                return result
            }
            elements.append(result.get()!)
            current = result
        }
        
        return current.success(elements)
    }
    
    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        var pos = position
        for parser in parsers {
            if let nextpos = parser.fastParseOn(buffer, pos) {
                pos = nextpos
            }
            else {
                return nil
            }
        }
        return pos
    }

    public override func seq(_ others: Parser...) -> SequenceParser {
        var parsers = self.parsers
        for other in others {
            parsers.append(other)
        }
        return SequenceParser(parsers)
    }
    
    public override func copy() -> Parser {
        return SequenceParser(parsers)
    }
}

extension Parser {
	static func + (lhs: Parser, rhs: Parser) -> Parser {
        return lhs.seq(rhs)
    }
}

extension SequenceParser: CustomStringConvertible {
    public var description: String {
        let className = String(describing: type(of: self))
        
        return "\(className)"
    }
}
