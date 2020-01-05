//
//  NotParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class NotParser: DelegateParser {
    
    let message: String
    
    public init(_ delegate: Parser, _ message: String) {
        self.message = message
        super.init(delegate)
    }
    
    public override func parseOn(_ context: Context) -> Result {
        let result = delegate.parseOn(context)
        if result.isFailure() {
            return context.success(NSNull())
        }
        else {
            return context.failure(message)
        }
    }
    
    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        let result = delegate.fastParseOn(buffer, position)
        return result == nil ? position : nil
    }

    public override func hasEqualProperties(_ other: Parser) -> Bool {
        if let oth = other as? NotParser {
            return super.hasEqualProperties(other)
                && oth.message == message
        }
        
        return false
    }
    
    public override func copy() -> Parser {
        return NotParser(delegate, message)
    }
}

extension Parser {
    public func not(_ message: String = "unexpected") -> Parser {
      return NotParser(self, message)
    }
}
