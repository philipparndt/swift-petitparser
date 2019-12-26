//
//  DelegateParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class DelegateParser: Parser {
    // swiftlint:disable weak_delegate
    var delegate: Parser
    
    public init(_ delegate: Parser) {
        self.delegate = delegate
        super.init()
    }
    
    public override func parseOn(_ context: Context) -> Result {
        return delegate.parseOn(context)
    }
    
    public override func replace(_ source: Parser, _ target: Parser) {
        super.replace(source, target)
        if delegate === source {
            delegate = target
        }
    }
    
    public override func getChildren() -> [Parser] {
        return [delegate]
    }
    
    public override func copy() -> Parser {
        return DelegateParser(delegate)
    }
}

extension DelegateParser: CustomStringConvertible {
    public var description: String {
        let className = String(describing: type(of: self))
        
        if self is RepeatingParser {
            let repeating = self as! RepeatingParser
            return "\(className)[\(repeating.getRange())]"
        }
        else {
            return "\(className)"
        }
    }
}
