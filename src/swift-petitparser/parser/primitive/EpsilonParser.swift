//
//  EpsilonParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-19.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class EpsilonParser: Parser {
    public override init() {
        super.init()
    }
    
    public override func parseOn(_ context: Context) -> Result {
        return context.success(NSNull())
    }
    
    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        return position
    }
    
    public override func copy() -> Parser {
        return EpsilonParser()
    }
}
