//
//  Result.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class AbstractResult: Context {
    
    let message: String?
    
    public init(_ message: String?, _ buffer: String, _ position: String.Index) {
        self.message = message
        
        super.init(buffer, position)
    }
    
    func isSuccess() -> Bool {
        return false
    }
    
    func isFailure() -> Bool {
        return false
    }
}

public protocol Result: AbstractResult {
    func get<T>() -> T?
}
