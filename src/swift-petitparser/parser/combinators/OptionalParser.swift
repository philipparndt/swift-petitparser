//
//  OptionalParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class OptionalParser: DelegateParser {
    let otherwise: NSObject?
    
    public init(_ delegate: Parser, _ otherwise: NSObject?) {
        self.otherwise = otherwise
        super.init(delegate)
    }
    
    public override func parseOn(_ context: Context) -> Result {
        let result = delegate.parseOn(context)
        if result.isSuccess() {
            return result
        }
        else {
            return context.success(otherwise ?? NSNull())
        }
    }

    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        let result = delegate.fastParseOn(buffer, position)
        return result == nil ? position : result
    }

    public override func hasEqualProperties(_ other: Parser) -> Bool {
        if let oth = other as? OptionalParser {
            return super.hasEqualProperties(other)
            &&
                (otherwise == nil && oth.otherwise == nil) ||
                (otherwise != nil && oth.otherwise != nil && oth.otherwise! === otherwise!)
        }
        
        return false
    }
    
    public override func copy() -> Parser {
        return OptionalParser(delegate, otherwise)
    }
}

extension Parser {
    public func optional() -> Parser {
        return optional(nil)
    }
    
    public func optional(_ otherwise: NSObject?) -> Parser {
        return OptionalParser(self, otherwise)
    }
}
