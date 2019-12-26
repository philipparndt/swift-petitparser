//
//  Token.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class Token {
    let buffer: String
    let start: String.Index
    let stop: String.Index
    let value: AnyObject
    
    static let NEWLINE_PARSER: Parser = CharacterParser.of("\n").or(CharacterParser.of("\r").seq(CharacterParser.of("\n").optional()))
    
    public init(_ buffer: String, _ start: String.Index, _ stop: String.Index, _ value: AnyObject) {
        self.buffer = buffer
        self.start = start
        self.stop = stop
        self.value = value
    }
    
    public func getInput() -> String {
        return String(buffer[start..<stop])
    }

    public func getLength() -> String.IndexDistance {
        return buffer.distance(from: start, to: stop)
    }
    
    /**
     * The line number of the token.
     */
    func getLine() -> Int {
        return Token.lineAndColumnOf(buffer, start).0
    }

    /**
     * The column number of this token.
     */
    func getColumn() -> Int {
        return Token.lineAndColumnOf(buffer, start).1
    }
    
    public class func lineAndColumnOf(_ buffer: String, _ position: String.Index) -> (Int, Int) {
        let pos = position.utf16Offset(in: buffer)
        let tokens: [Token] = NEWLINE_PARSER.token().matchesSkipping(buffer)
        var line = 1
        var offset = 0

        for token in tokens {
            if pos < token.stop.utf16Offset(in: buffer) {
                return (line, pos - offset + 1)
            }
            
            line += 1
            offset = token.stop.utf16Offset(in: buffer)
        }

        return (line, pos - offset + 1)
    }
}

extension Token: Equatable {
    public static func == (lhs: Token, rhs: Token) -> Bool {
      return lhs.start == rhs.start &&
        lhs.stop == rhs.stop &&
        lhs.buffer == rhs.buffer &&
        ObjectIdentifier(lhs.value) == ObjectIdentifier(rhs.value)
    }
}

extension Token: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(start)
        hasher.combine(stop)
        hasher.combine(buffer)
        hasher.combine(ObjectIdentifier(value))
    }
}
