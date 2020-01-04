//
//  CharacterParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class CharacterParser: Parser {
    let message: String
    let matcher: CharacterPredicate
    
    init(_ matcher: CharacterPredicate, _ message: String) {
        self.matcher = matcher
        self.message = message
        
        super.init()
    }
    
    public class func of(_ predicate: CharacterPredicate, _ message: String) -> CharacterParser {
        return CharacterParser(predicate, message)
    }
    
    public class func of(_ character: Character) -> CharacterParser {
        return of(character, "'\(character)' expected")
    }
    
    public class func of(_ character: Character, _ message: String) -> CharacterParser {
        return of(CharacterPredicates.of(character), message)
    }
    
    public class func any(_ message: String = "any character expected") -> CharacterParser {
        return CharacterParser(CharacterPredicates.any(), message)
    }
    
    public class func anyOf(_ chars: String) -> CharacterParser {
      return anyOf(chars, "any of '\(chars)' expected")
    }

    public class func anyOf(_ chars: String, _ message: String) -> CharacterParser {
      return of(CharacterPredicates.anyOf(chars), message)
    }

    public class func none(_ message: String = "no character expected") -> CharacterParser {
      return of(CharacterPredicates.none(), message)
    }

    public class func noneOf(_ chars: String) -> CharacterParser {
      return noneOf(chars, "none of '\(chars)' expected")
    }

    public class func noneOf(_ chars: String, _ message: String) -> CharacterParser {
      return of(CharacterPredicates.noneOf(chars), message)
    }

    public class func digit(_ message: String = "digit expected") -> CharacterParser {
        return CharacterParser(CharacterPredicates.digit(), message)
    }

    public class func letter(_ message: String = "letter expected") -> CharacterParser {
        return CharacterParser(CharacterPredicates.letter(), message)
    }

    public class func lowerCase(_ message: String = "lowercase letter expected") -> CharacterParser {
        return CharacterParser(CharacterPredicates.lowerCase(), message)
    }
    
    public class func pattern(_ charPattern: String) -> CharacterParser {
      return pattern(charPattern, "[\(charPattern)] expected")
    }
    
    public class func pattern(_ charPattern: String, _ message: String) -> CharacterParser {
        return of(CharacterPredicates.pattern(charPattern), message)
    }
    
    public class func range(_ start: Character, _ stop: Character) -> CharacterParser {
        return range(start, stop, "\(start)..\(stop) expected")
    }
    
    public class func range(_ start: Character, _ stop: Character, _ message: String) -> CharacterParser {
        return of(CharacterPredicates.range(start, stop), message)
    }
    
    public class func upperCase(_ message: String = "uppercase letter expected") -> CharacterParser {
        return CharacterParser(CharacterPredicates.upperCase(), message)
    }

    public class func whitespace(_ message: String = "whitespace expected") -> CharacterParser {
        return CharacterParser(CharacterPredicates.whitespace(), message)
    }

    public class func word(_ message: String = "letter or digit expected") -> CharacterParser {
        return CharacterParser(CharacterPredicates.word(), message)
    }
    
    public override func parseOn(_ context: Context) -> Result {
        let buffer = context.buffer
        let position = context.position

        if position < buffer.endIndex {
            let result = buffer[position]
            
            if matcher.test(result) {
                return context.success(result, buffer.index(after: position))
            }
        }
        return context.failure(message)
    }
    
    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        if position < buffer.endIndex {
            let result = buffer[position]
            
            if matcher.test(result) {
                return buffer.index(after: position)
            }
        }
        
        return nil
    }
    
	public override func neg(_ message: String = "not expected") -> Parser {
        // Return an optimized version of the receiver.
        return CharacterParser.of(matcher.not(), message)
    }

    public override func copy() -> Parser {
        return CharacterParser(matcher, message)
    }
}

extension CharacterParser: CustomStringConvertible {
    public var description: String {
        return "CharacterParser[\(message)]"
    }
}
