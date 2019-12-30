//
//  CharacterPredicate.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public struct CharacterPredicate {
    var test: (Character) -> Bool

    init(matcher: @escaping (Character) -> Bool) {
        self.test = matcher
    }
    
    public func not() -> CharacterPredicate {
        return CharacterPredicate(matcher: {
            !self.test($0)
        })
    }
}

public class CharacterPredicates {
    static func backward(_ s1: String, _ s2: String) -> Bool {
        return s1 > s2
    }
    
    static func any() -> CharacterPredicate {
        return CharacterPredicate(matcher: { _ in true })
    }
    
    static func anyOf(_ string: String) -> CharacterPredicate {
        let ranges = Array(string).map { CharacterRange($0, $0) }
        return CharacterRange.toCharacterPredicate(ranges)
    }
    
    static func none() -> CharacterPredicate {
        return CharacterPredicate(matcher: { _ in false })
    }
    
    static func noneOf(_ string: String) -> CharacterPredicate {
        let ranges = Array(string).map { CharacterRange($0, $0) }
        return CharacterRange.toCharacterPredicate(ranges).not()
    }
    
    static func of(_ character: Character) -> CharacterPredicate {
        return CharacterPredicate(matcher: { value in value == character })
    }
    
    static func range(_ start: Character, _ stop: Character) -> CharacterPredicate {
        return CharacterPredicate(matcher: { value in start <= value && value <= stop })
    }
    
    static func pattern(_ charPattern: String) -> CharacterPredicate {
        return PatternParser.pattern.parse(charPattern).get()!
    }
    
    static func ranges(_ starts: [Character], _ stops: [Character]) -> CharacterPredicate {
        if starts.count != starts.count {
            fatalError("Invalid range sizes.")
        }
        
        for i in 0...starts.count-1 {
            if starts[i].asciiValue! > stops[i].asciiValue! {
                fatalError("Invalid range: \(starts[i])-\(stops[i])")
            } else if i + 1 < starts.count && starts[i + 1] <= stops[i] {
                fatalError("Invalid sequence.")
            }
        }
        
        return CharacterPredicate(matcher: { value in
            let index = bisect(starts, value)
            return index >= 0 || index < -1 && value <= stops[-index - 2]
        })
    }
    
    class func bisect(_ values: [Character], _ value: Character) -> Int {
        var min = 0
        var max = values.count
        while min < max {
            let mid = min + ((max - min) >> 1)
            let midValue = values[mid].asciiValue!
            
            if midValue == value.asciiValue! {
                return mid
            }
            else if midValue < value.asciiValue! {
                min = mid + 1
            }
            else {
                max = mid
            }
        }
        return -(min + 1)
    }

    static func digit() -> CharacterPredicate {
        return CharacterPredicate(matcher: { $0.isNumber })
    }
    
    static func letter() -> CharacterPredicate {
        return CharacterPredicate(matcher: { $0.isLetter })
    }
    
    static func lowerCase() -> CharacterPredicate {
        return CharacterPredicate(matcher: { $0.isLowercase })
    }
    
    static func upperCase() -> CharacterPredicate {
        return CharacterPredicate(matcher: { $0.isUppercase })
    }
    
    static func hex() -> CharacterPredicate {
        return CharacterPredicate(matcher: { $0.isHexDigit })
    }
    
    static func whitespace() -> CharacterPredicate {
        return CharacterPredicate(matcher: { $0.isWhitespace })
    }
    
    static func word() -> CharacterPredicate {
        return CharacterPredicate(matcher: { $0.isLetter || $0.isNumber })
    }
 
}

class PatternParser {
    static let patternSimple = CharacterParser.any()
        .map { CharacterRange($0, $0) }
        
    static let patternRange = CharacterParser.any()
    .seq(CharacterParser.of("-"))
    .seq(CharacterParser.any())
    .map { (array: [Character]) -> CharacterRange in CharacterRange(array[0], array[2]) }

    static let patternPositive = patternRange
        .or(patternSimple).star()
        .map(CharacterRange.toCharacterPredicate)
    
    private static let unbox: ([Any]) -> CharacterPredicate = {
        let range = $0[1] as! CharacterPredicate
        if $0[0] is NSNull {
            return range
        }
        else {
            return range.not()
        }
    }
    public static let pattern = CharacterParser.of("^").optional().seq(patternPositive)
        .map(unbox)
        .end()
}
