//
//  ActionParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class ActionParser<T, R>: DelegateParser {
    let function: (T) -> R
    let hasSideEffects: Bool
    
    init(_ delegate: Parser, _ function: @escaping (T) -> R) {
        self.function = function
        self.hasSideEffects = false
        super.init(delegate)
    }
    
    init(_ delegate: Parser, _ function: @escaping (T) -> R, _ hasSideEffects: Bool) {
        self.function = function
        self.hasSideEffects = hasSideEffects
        super.init(delegate)
    }
    
    public override func parseOn(_ context: Context) -> Result {
        let result = delegate.parseOn(context)
        
        if result.isSuccess() {
            let value: T = result.get()!
            
            let mapped = function(value)
            return result.success(mapped)
        }
        return result
    }
    
    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        return hasSideEffects ? super.fastParseOn(buffer, position) :
                delegate.fastParseOn(buffer, position)
    }

    public override func copy() -> Parser {
        return ActionParser(delegate, function)
    }
}
