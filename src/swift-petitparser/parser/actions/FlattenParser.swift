//
//  FlattenParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-19.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class FlattenParser: DelegateParser {
    
    let message: String?
    
    override init(_ delegate: Parser) {
        self.message = nil
        super.init(delegate)
    }
    
    init(_ delegate: Parser, _ message: String?) {
        self.message = message
        super.init(delegate)
    }
    
    public override func parseOn(_ context: Context) -> Result {
        if message == nil {
            let result = delegate.parseOn(context)
            if result.isSuccess() {
                let flattened = context.buffer[context.position..<result.position]
                return result.success(String(flattened))
            }
            else {
                return result
            }
        }
        else {
            // If we have a message we can switch to fast mode.
            let position = delegate.fastParseOn(context.buffer, context.position)
            if position == nil {
                return context.failure(message!)
            }
            
            let output = context.buffer[context.position..<position!]
            return context.success(String(output), position!)
        }
    }
    
    public override func copy() -> Parser {
        return FlattenParser(delegate, message)
    }
}

extension Parser {
    public func flatten() -> Parser {
      return FlattenParser(self)
    }
    
    public func flatten(_ message: String) -> Parser {
      return FlattenParser(self, message)
    }
}
