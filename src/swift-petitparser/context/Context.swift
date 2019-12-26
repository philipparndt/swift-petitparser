//
//  Context.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class Context {
    let buffer: String
    let position: String.Index
    
    init(_ buffer: String, _ position: String.Index) {
        self.buffer = buffer
        self.position = position
    }
    
    public func success(_ value: Any) -> Success {
        return success(value, position)
    }
    
    public func success(_ value: Any, _ position: String.Index) -> Success {
        return Success(buffer, position, value)
    }
    
    public func failure(_ message: String) -> Failure {
        return failure(message, position)
    }
    
    public func failure(_ message: String, _ position: String.Index) -> Failure {
        return Failure(buffer, position, message)
    }
}

extension Context: CustomStringConvertible {
    public var description: String {
        let className = String(describing: type(of: self))
        let tuple = Token.lineAndColumnOf(buffer, position)
        let string = "\(className)[\(tuple.0):\(tuple.1)]"
        
        if self is Failure {
            let failure = self as! Failure
            return "\(string): \(failure.message ?? "")"
        }
        else if self is Success {
            let success = self as! Success
            return "\(string): \(success.result)"
        }
        else {
            return string
        }
    }
}
