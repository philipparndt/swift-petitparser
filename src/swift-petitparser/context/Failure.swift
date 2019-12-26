//
//  Failure.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class Failure: AbstractResult, Result {

    public init(_ buffer: String, _ position: String.Index, _ message: String) {
        super.init(message, buffer, position)
    }

    override func isFailure() -> Bool {
        return true
    }

    public func get<T>() -> T? {
        return nil
    }
}
