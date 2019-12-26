//
//  Mirror.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-23.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class Mirror {
    
    let parser: Parser
    
    init(_ parser: Parser) {
        self.parser = parser
    }
    
    public class func of(_ parser: Parser) -> Mirror {
        return Mirror(parser)
    }
    
    public func iterate() -> [Parser] {
        var todo: [Parser] = []
        todo.append(parser)
        
        var seen: Set<Parser> = Set()
        seen.insert(parser)
        
        var result: [Parser] = []
        while !todo.isEmpty {
            let current = todo.remove(at: todo.endIndex - 1)
            result.append(current)
            for parser in current.getChildren() {
                if !seen.contains(parser) {
                    todo.append(parser)
                    seen.insert(parser)
                }
            }
        }
        
        return result
    }
    
    public func transform(_ transformer: (Parser) -> Parser) -> Parser {
        var mapping: [Parser: Parser] = [:]
        
        for parser in iterate() {
            mapping[parser] = transformer(parser.copy())
        }

        var seen: Set<Parser> = Set(Array(mapping.values))
        var todo = Array(mapping.values)
        
        while !todo.isEmpty {
            let parent = todo.remove(at: todo.endIndex - 1)
            for child in parent.getChildren() {
                if mapping[child] != nil {
                    parent.replace(child, mapping[child]!)
                }
                else if !seen.contains(child) {
                    seen.insert(child)
                    todo.append(child)
                }
            }
        }

        return mapping[parser]!
    }
}
