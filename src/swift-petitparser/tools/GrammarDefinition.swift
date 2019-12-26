//
//  GrammarDefinition.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-22.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class GrammarDefinition {
    
    var parsers: [String: Parser] = [:]
    
    func resolve(_ name: String) -> Parser {
        return parsers[name]!
    }
    
    func ref(_ name: String) -> Parser {
        return Reference(name, resolve)
    }
    
    func def(_ name: String, _ parser: Parser) {
        if parsers.keys.contains(name) {
            fatalError("Duplicate production: \(name)")
        }
        else {
            parsers[name] = parser
        }
    }
    
    func redef(_ name: String, _ parser: Parser) {
        if !parsers.keys.contains(name) {
            fatalError("Undefined production: \(name)")
        }
        else {
            parsers[name] = parser
        }
    }
    
    func redef(_ name: String, _ function: (Parser) -> Parser) {
        if !parsers.keys.contains(name) {
            fatalError("Undefined production: \(name)")
        }
        else {
            parsers[name] = function(parsers[name]!)
        }
    }
    
    func action<S, T>(_ name: String, _ function: @escaping (S) -> T) {
        redef(name, { parser in parser.map(function) })
    }
    
    public func build() -> Parser {
        return build("start")
    }
    
    public func build(_ name: String) -> Parser {
        return resolve(Reference(name, resolve))
    }
    
    func resolve(_ reference: Reference) -> Parser {
        var mapping: [Reference: Parser] = [:]
        var todo: [Parser] = []
        todo.append(dereference(&mapping, reference))
        var seen: Set<Parser> = Set(todo)
        
        while !todo.isEmpty {
            let parent = todo.remove(at: todo.count - 1)
            
            for child in parent.getChildren() {
                var current = child
                if current is Reference {
                    let referenced = dereference(&mapping, current as! Reference)
                    parent.replace(current, referenced)
                    current = referenced
                }
                if !seen.contains(current) {
                    seen.insert(current)
                    todo.append(current)
                }
            }
        }
        
        return mapping[reference]!
    }

    func dereference(_ mapping: inout [Reference: Parser], _ reference: Reference) -> Parser {
        var parser = mapping[reference]
        
        if parser == nil {
            var references: [Reference] = []
            references.append(reference)
            parser = reference.resolve()
            
            while parser is Reference {
                let otherReference = parser as! Reference
                if references.contains(otherReference) {
                    fatalError("Recursive references detected.")
                }
                references.append(otherReference)
                parser = otherReference.resolve()
            }
            
            for otherReference in references {
                mapping[otherReference] = parser
            }
        }
        
        return parser!
    }
}

class Reference: Parser {
    let name: String
    var resolver: (String) -> Parser
    
    init(_ name: String, _ resolver: @escaping (String) -> Parser) {
        self.name = name
        self.resolver = resolver
        
        super.init()
    }
    
    func resolve() -> Parser {
        return resolver(name)
    }
}

extension Parser: Hashable {
    public func hash(into hasher: inout Hasher) {
        if self is Reference {
            let ref = self as! Reference
            hasher.combine(ref.name)
        }
        else {
            hasher.combine(ObjectIdentifier(self))
        }
    }
}

extension Parser: Equatable {
    public static func == (lhs: Parser, rhs: Parser) -> Bool {
        if lhs is Reference && rhs is Reference {
            let left = lhs as! Reference
            let right = rhs as! Reference
            return left.name == right.name
        }
        else {
            return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
        }
    }
}
