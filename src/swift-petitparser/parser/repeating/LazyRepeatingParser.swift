//
//  LazyRepeatingParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-19.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

class LazyRepeatingParser: LimitedRepeatingParser {
    override func parseOn(_ context: Context) -> Result {
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
        
        while true {
            let limiter = limit.parseOn(current)
            if limiter.isSuccess() {
                return current.success(elements)
            }
            else {
                if max != RepeatingParser.UNBOUNDED && elements.count >= max {
                    return limiter
                }
                
                let result = delegate.parseOn(current)
                if result.isFailure() {
                    return limiter
                }
                
                elements.append(result.get()!)
                current = result
            }
        }
    }
    
    override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        var count = 0
        var current = position

        while count < min {
            let result = delegate.fastParseOn(buffer, current)
            if result == nil {
                return nil
            }
            current = result!
            count += 1
        }
        
        while true {
            let limiter = limit.fastParseOn(buffer, current)
            if limiter != nil {
                return current
            }
            else {
                if max != RepeatingParser.UNBOUNDED && count >= max {
                    return nil
                }
                
                let result = delegate.fastParseOn(buffer, current)
                if result == nil {
                    return nil
                }
                current = result!
                count += 1
            }
        }
    }
    
    override func copy() -> Parser {
        return LazyRepeatingParser(delegate, limit, min, max)
    }
}
