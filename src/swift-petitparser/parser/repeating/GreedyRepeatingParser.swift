//
//  GreedyRepeatingParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-19.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

class GreedyRepeatingParser: LimitedRepeatingParser {
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
        
        var contexts: [Context] = []
        contexts.append(current)
        while max == RepeatingParser.UNBOUNDED || elements.count < max {
            let result = delegate.parseOn(current)
            if result.isFailure() {
                break
            }
            elements.append(result.get()!)
            current = result
            contexts.append(current)
        }
        
        while true {
            let limiter = limit.parseOn(contexts[contexts.count - 1])
            if limiter.isSuccess() {
                return contexts[contexts.count - 1].success(elements)
            }
            if elements.isEmpty {
                return limiter
            }
            contexts.remove(at: contexts.count - 1)
            elements.remove(at: elements.count - 1)
            
            if contexts.isEmpty {
                return limiter
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
        
        var positions: [String.Index] = []
        positions.append(current)
        while max == RepeatingParser.UNBOUNDED || count < max {
            let result = delegate.fastParseOn(buffer, current)
            if result == nil {
              break
            }
            current = result!
            positions.append(current)
            count+=1
        }
        
        while true {
            let limiter = limit.fastParseOn(buffer, positions[positions.count - 1])
            if limiter != nil {
                return positions[positions.count - 1]
            }
            // swiftlint false positive
            // swiftlint:disable empty_count
            if count == 0 {
                return nil
            }
            positions.remove(at: positions.count - 1)
            count -= 1
            if positions.isEmpty {
                return nil
            }
        }
    }
    
    override func copy() -> Parser {
        return GreedyRepeatingParser(delegate, limit, min, max)
    }
}
