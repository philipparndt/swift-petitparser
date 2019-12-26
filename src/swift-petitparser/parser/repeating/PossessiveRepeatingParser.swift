//
//  PossessiveRepeatingParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class PossessiveRepeatingParser: RepeatingParser {
    public override func parseOn(_ context: Context) -> Result {
        var current = context
        var elements: [Any] = []

        while elements.count < min {
            let result = delegate.parseOn(current)
            if result.isFailure() {
                return result
            }
            elements.append(result.get()!)
            current = result
        }
        
        while max == RepeatingParser.UNBOUNDED || elements.count < max {
            let result = delegate.parseOn(current)
            if result.isFailure() {
                return current.success(elements)
            }
            elements.append(result.get()!)
            current = result
        }
        
        return current.success(elements)
    }
    
    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        var count = 0
        var current = position
        
        while count < min {
            let result = delegate.fastParseOn(buffer, current)
            if result == nil {
                return result
            }
            current = result!
            count+=1
        }

        while max == RepeatingParser.UNBOUNDED || count < max {
            let result = delegate.fastParseOn(buffer, current)
            if result == nil {
              return current
            }
            current = result!
            count+=1
        }
        
        return current
    }
    
    public override func copy() -> Parser {
        return PossessiveRepeatingParser(delegate, min, max)
    }
}
