//
//  ValidationParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-28.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class ValidationParser<T>: DelegateParser {
    let message: String
    let validator: (Context, T) -> Result?

    public init(_ delegate: Parser, _ validator: @escaping (Context, T) -> Result?, _ message: String) {
        self.message = message
        self.validator = validator
        super.init(delegate)
    }
    
    public override func parseOn(_ context: Context) -> Result {
        let result = delegate.parseOn(context)
        
        if result.isFailure() {
            return result
        }
        else {
            let value: T = result.get()!
            return validator(context, value) ?? result
        }
    }
    
    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        let result = delegate.fastParseOn(buffer, position)
        return result == nil ? position : nil
    }

    public override func hasEqualProperties(_ other: Parser) -> Bool {
        if let oth = other as? ValidationParser {
            return super.hasEqualProperties(other)
                && oth.message == message
        }
        
        return false
    }
    
    public override func copy() -> Parser {
        return ValidationParser(delegate, validator, message)
    }
}

extension Parser {
    public func validate<T>(_ validator: @escaping (Context, T) -> Result?) -> Parser {
      return validate(validator, "validation failed")
    }
    
    public func validate<T>(_ validator: @escaping (Context, T) -> Result?, _ message: String) -> Parser {
      return ValidationParser(self, validator, message)
    }
}
