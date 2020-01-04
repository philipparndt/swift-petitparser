//
//  Parser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class Parser {
    
    @discardableResult public func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        let result = parseOn(Context(buffer, position))
        return result.isSuccess() ? result.position : nil
    }
    
    public func parseOn(_ context: Context) -> Result {
        let className = String(describing: type(of: self))
        fatalError("\(className) must overwrite parseOn")
    }
    
    public func parse(_ input: String) -> Result {
        return parseOn(Context(input, input.startIndex))
    }
    
    public func accept(_ input: String) -> Bool {
        return fastParseOn(input, input.startIndex) != nil
    }
    
    public func matches<T>(_ input: String) -> [T] {
        var result: [T] = []
        let function: (T) -> Void = {result.append($0)}
        
        and().mapWithSideEffects(function)
            .seq(CharacterParser.any())
            .or(CharacterParser.any())
            .star()
            .fastParseOn(input, input.startIndex)
      
        return result
    }
    
    public func matchesSkipping<T>(_ input: String) -> [T] {
          var result: [T] = []
          let function: (T) -> Void = {result.append($0)}
          
          mapWithSideEffects(function)
            .or(CharacterParser.any())
            .star()
            .fastParseOn(input, input.startIndex)
        
          return result
    }
    
    public func seq(_ others: Parser...) -> SequenceParser {
        var parsers = others
        parsers.insert(self, at: 0)
        return SequenceParser(parsers)
    }
    
    public func or(_ others: Parser...) -> ChoiceParser {
        var parsers = others
        parsers.insert(self, at: 0)
        return ChoiceParser(parsers)
    }
    
    public func neg(_ message: String = "not expected") -> Parser {
        return not(message).seq(CharacterParser.any()).pick(1)
    }
    
    public func map<A, B>(_ function: @escaping (A) -> B) -> Parser {
      return ActionParser(self, function)
    }
    
    public func mapWithSideEffects<A, B>(_ function: @escaping (A) -> B) -> Parser {
      return ActionParser(self, function, true)
    }
    
    public func pick(_ index: Int) -> Parser {
        let function: ([Any]) -> Any = Functions.nthOfList(index)
        return map(function)
    }

    public func permute(_ indexes: Int...) -> Parser {
        return map(Functions.permutationOfList(indexes))
    }
    
    public func separatedBy(_ separator: Parser) -> Parser {
        let function: ([Any]) -> [Any] = Functions.separateByUnpack()
        
        return SequenceParser(self, SequenceParser(separator, self).star())
            .map(function)
    }
    
    public func delimitedBy(_ separator: Parser) -> Parser {
        let function: ([Any]) -> [Any] = Functions.delimitedByUnpack()
        
        return separatedBy(separator).seq(separator.optional())
        .map(function)
    }
    
    public func replace(_ source: Parser, _ target: Parser) {
        // no referring parsers
    }

    public func hasEqualProperties(_ other: Parser) -> Bool {
      return true
    }
    
    public func getChildren() -> [Parser] {
        return []
    }
    
    public func copy() -> Parser {
        return Parser()
    }
}

extension Parser {
    /**
     * Recursively tests for structural similarity of two parsers.
     *
     * <p>The code can automatically deals with recursive parsers and parsers
     * that refer to other parsers. This code is supposed to be overridden by
     * parsers that add other state.
     */
    public func isEqualTo(_ other: Parser) -> Bool {
        var seen: Set<Parser> = Set()
        return isEqualTo(other, &seen)
    }

    /**
     * Recursively tests for structural similarity of two parsers.
     */
    func isEqualTo(_ other: Parser, _ seen: inout Set<Parser>) -> Bool {
        if seen.contains(self) {
            return true
        }
        seen.insert(self)
        
        return isSameClass(other)
            && hasEqualProperties(other) && hasEqualChildren(other, &seen)
    }
    
    func isSameClass(_ other: Parser) -> Bool {
        return object_getClassName(self) == object_getClassName(other)
    }
    
    /**
     * Compares the children of two parsers.
     *
     * <p>Normally subclasses should not override this method, but instead {@link
     * #getChildren()}.
     */
    func hasEqualChildren(_ other: Parser, _ seen: inout Set<Parser>) -> Bool {
        let selfChildren = getChildren()
        let otherChildren = other.getChildren()
        
        if selfChildren.count != otherChildren.count {
            return false
        }

        for i in 0 ..< selfChildren.count {
            if !selfChildren[i].isEqualTo(otherChildren[i], &seen) {
                return false
            }
        }

        return true
    }

}
