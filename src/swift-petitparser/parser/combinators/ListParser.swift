//
//  ListParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class ListParser: Parser {
    
    var parsers: [Parser]
    
    public init(_ parsers: [Parser]) {
        self.parsers = parsers
        
        super.init()
    }
    
    public init(_ parsers: Parser...) {
        self.parsers = parsers
        
        super.init()
    }
    
    public override func replace(_ source: Parser, _ target: Parser) {
        super.replace(source, target)
        
        if let index = (parsers.firstIndex { $0 === source }) {
             parsers[index] = target
        }
    }

    public override func getChildren() -> [Parser] {
        return parsers
    }
}
