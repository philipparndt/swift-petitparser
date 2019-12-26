//
//  TokenParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-19.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class TokenParser: DelegateParser {
    
    public override func parseOn(_ context: Context) -> Result {
        let result = delegate.parseOn(context)
        if result.isSuccess() {
            let token = Token(context.buffer, context.position, result.position, result.get()!)
            return result.success(token)
        }
        else {
            return result
        }
    }
    
    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        return delegate.fastParseOn(buffer, position)
    }
    
    public override func copy() -> Parser {
        return TokenParser(delegate)
    }
}

extension Parser {
    public func token() -> Parser {
      return TokenParser(self)
    }
}
