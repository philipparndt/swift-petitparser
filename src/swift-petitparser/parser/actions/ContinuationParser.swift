//
//  ContinuationParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-19.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public protocol ContinuationHandler {
    func apply(_ continuation: @escaping (Context) -> Result, _ context: Context) -> Result
}

public class ContinuationParser: DelegateParser {
    let handler: ContinuationHandler
    
    public init(_ delegate: Parser, _ handler: ContinuationHandler) {
        self.handler = handler
        super.init(delegate)
    }
    
    public override func parseOn(_ context: Context) -> Result {
        handler.apply(super.parseOn, context)
    }
    
    public override func hasEqualProperties(_ other: Parser) -> Bool {
        return ObjectIdentifier(self) == ObjectIdentifier(other)
    }
    
    public override func copy() -> Parser {
        return ContinuationParser(delegate, handler)
    }
}

extension Parser {
    public func callCC(_ handler: ContinuationHandler) -> Parser {
      return ContinuationParser(self, handler)
    }
}
