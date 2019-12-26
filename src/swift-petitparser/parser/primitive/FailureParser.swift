//
//  FailureParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class FailureParser: Parser {
    
    let message: String
    
    public init(_ message: String) {
        self.message = message
        super.init()
    }
    
    public class func withMessage(_ message: String) -> Parser {
        return FailureParser(message)
    }
    
    public override func parseOn(_ context: Context) -> Result {
        return context.failure(message)
    }
    
    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        return nil
    }
    
    public override func hasEqualProperties(_ other: Parser) -> Bool {
        if let oth = other as? FailureParser {
            return super.hasEqualProperties(other)
                && oth.message == message
        }
        
        return false
    }
    
    public override func copy() -> Parser {
        return FailureParser(message)
    }
}
