//
//  AndParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class AndParser: DelegateParser {
    
    public override func parseOn(_ context: Context) -> Result {
        let result = delegate.parseOn(context)
        if result.isSuccess() {
            return context.success(result.get()!)
        }
        else {
            return result
        }
    }
    
    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        let result = delegate.fastParseOn(buffer, position)
        return result == nil ? nil : position
    }
    
    public override func copy() -> Parser {
        return AndParser(delegate)
    }
}

extension Parser {
    public func and() -> Parser {
      return AndParser(self)
    }
}
