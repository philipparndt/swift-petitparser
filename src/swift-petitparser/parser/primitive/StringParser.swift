//
//  StringParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-19.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class StringParser: Parser {
    let size: String.IndexDistance
    let message: String
    let matcher: StringPredicate
    
    init(_ size: String.IndexDistance, _ matcher: StringPredicate, _ message: String) {
        self.size = size
        self.matcher = matcher
        self.message = message
        
        super.init()
    }
    
    public class func of(_ value: String) -> Parser {
        return of(value, "\(value) expected")
    }

    public class func of(_ value: String, _ message: String) -> Parser {
        let matcher = StringPredicate(matcher: { s in s.compare(value) == .orderedSame })
        let distance = value.distance(from: value.startIndex, to: value.endIndex)
        return StringParser(distance, matcher, message)
    }
    
    public class func ofIgnoringCase(_ value: String) -> Parser {
        return ofIgnoringCase(value, "\(value) expected")
    }

    public class func ofIgnoringCase(_ value: String, _ message: String) -> Parser {
        let matcher = StringPredicate(matcher: { s in s.caseInsensitiveCompare(value) == .orderedSame })
        let distance = value.distance(from: value.startIndex, to: value.endIndex)
        return StringParser(distance, matcher, message)
    }
    
    public override func parseOn(_ context: Context) -> Result {
        let distance = context.buffer.distance(from: context.position, to: context.buffer.endIndex)
        if distance >= size {
            let end = context.buffer.index(context.position, offsetBy: size)
            let result = String(context.buffer[context.position..<end])
            if matcher.test(result) {
                 return context.success(result, end)
            }
        }
        return context.failure(message)
    }
    
    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        let distance = buffer.distance(from: position, to: buffer.endIndex)
        if distance >= size {
            let end = buffer.index(position, offsetBy: size)
            let result = String(buffer[position..<end])
            if matcher.test(result) {
                 return end
            }
        }
        return nil
    }
    
    public override func hasEqualProperties(_ other: Parser) -> Bool {
         if let oth = other as? StringParser {
            return super.hasEqualProperties(other)
                && oth.size == size
                && oth.message == message
                && ObjectIdentifier(oth.matcher) == ObjectIdentifier(matcher)
        }
        return false
    }
    
    public override func copy() -> Parser {
        return StringParser(size, matcher, message)
    }
}
