//
//  EndOfInputParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class EndOfInputParser: Parser {
    let message: String
    
    init(_ message: String) {
        self.message = message
        
        super.init()
    }
    
    public override func parseOn(_ context: Context) -> Result {
        let range = context.position..<context.buffer.endIndex
        return range.isEmpty ? context.success(NSNull()) : context.failure(message)
    }
    
    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        return position < buffer.endIndex ? nil : position
    }
    
    public override func hasEqualProperties(_ other: Parser) -> Bool {
        if let oth = other as? EndOfInputParser {
            return super.hasEqualProperties(other)
                && oth.message == message
        }
        
        return false
    }
    
    public override func copy() -> Parser {
        return EndOfInputParser(message)
    }
}

extension Parser {
    public func end() -> Parser {
        return end("end of input expected")
    }

    public func end(_ message: String) -> Parser {
        let parser = EndOfInputParser(message)
        return SequenceParser(self, parser).pick(0)
    }
}
