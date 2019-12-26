//
//  LimitedRepeatingParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-19.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

class LimitedRepeatingParser: RepeatingParser {
    var limit: Parser
    
    init(_ delegate: Parser, _ limit: Parser, _ min: Int, _ max: Int) {
        self.limit = limit
        super.init(delegate, min, max)
    }
    
    override func getChildren() -> [Parser] {
        return [delegate, limit]
    }
    
    override func replace(_ source: Parser, _ target: Parser) {
        super.replace(source, target)
        if limit === source {
            self.limit = target
        }
    }
}
