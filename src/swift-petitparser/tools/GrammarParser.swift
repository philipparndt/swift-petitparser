//
//  GrammarParser.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-22.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class GrammarParser: DelegateParser {
    public init(_ definition: GrammarDefinition) {
        super.init(definition.build())
    }
    
    public init(_ definition: GrammarDefinition, _ name: String) {
        super.init(definition.build(name))
    }
    
    public override func fastParseOn(_ buffer: String, _ position: String.Index) -> String.Index? {
        return delegate.fastParseOn(buffer, position)
    }
}
