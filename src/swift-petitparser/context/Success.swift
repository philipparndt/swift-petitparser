//
//  Success.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class Success: AbstractResult, Result {
    
    let result: Any
    
    public init(_ buffer: String, _ position: String.Index, _ result: Any) {
        self.result = result
        super.init("", buffer, position)
    }
    
    override func isSuccess() -> Bool {
        return true
    }
    
    public func get<T>() -> T? {
        return result as? T
    }
}
