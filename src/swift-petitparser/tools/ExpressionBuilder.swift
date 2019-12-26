//
//  ExpressionBuilder.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-20.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class ExpressionBuilder {
    let loopback = SettableParser.undefined()
    var groups: [ExpressionGroup] = []

    public func group() -> ExpressionGroup {
        let group = ExpressionGroup(loopback)
        groups.append(group)
        return group
    }

    public func build() -> Parser {
        var parser = FailureParser.withMessage("Highest priority group should define a primitive parser.")
        for group in groups {
            parser = group.build(parser)
        }
        loopback.set(parser)
        return parser
    }
}
