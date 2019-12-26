//
//  SettableParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class SettableParser: DelegateParser {
    
    public class func undefined() -> SettableParser {
        return undefined("Undefined parser")
    }
    
    public class func undefined(_ message: String) -> SettableParser {
        return with(FailureParser.withMessage(message))
    }
    
    public class func with(_ parser: Parser) -> SettableParser {
        return SettableParser(parser)
    }
    
    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        return delegate.fastParseOn(buffer, position)
    }
    
    public func get() -> Parser {
        return delegate
    }
    
    public func set(_ delegate: Parser) {
        self.delegate = delegate
    }
    
    public override func copy() -> Parser {
        return SettableParser(delegate)
    }
    
}

extension Parser {
    public func settable() -> SettableParser {
        return SettableParser.with(self)
    }
}
