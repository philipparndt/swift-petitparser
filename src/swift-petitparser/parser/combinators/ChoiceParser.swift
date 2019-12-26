//
//  ChoiceParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class ChoiceParser: ListParser {
   
    public override init(_ parsers: [Parser]) {
        super.init(parsers)
    }

    public override func parseOn(_ context: Context) -> Result {
        var result: Result = Failure("", "".endIndex, "")
        
        for parser in parsers {
            result = parser.parseOn(context)
            if result.isSuccess() {
                return result
            }
        }
                    
        return result
    }
    
    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        for parser in parsers {
            if let result = parser.fastParseOn(buffer, position) {
                return result
            }
        }
                    
        return nil
    }
    
    public override func or(_ others: Parser...) -> ChoiceParser {
        var parsers = self.parsers
        for other in others {
            parsers.append(other)
        }
        return ChoiceParser(parsers)
    }
        
    public override func copy() -> Parser {
        return ChoiceParser(parsers)
    }
}

extension ChoiceParser: CustomStringConvertible {
    public var description: String {
        let className = String(describing: type(of: self))
        
        return "\(className)"
    }
}
