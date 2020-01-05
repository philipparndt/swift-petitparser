//
//  ParserOps.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2020-01-05.
//  Copyright © 2020 petitparser. All rights reserved.
//

import Foundation

postfix operator <+>
postfix operator <*>

extension Parser {
	static func + (lhs: Parser, rhs: Parser) -> Parser {
        return lhs.seq(rhs)
    }
	
	static func & (lhs: Parser, rhs: Parser) -> Parser {
        return lhs.and().seq(rhs)
    }
	
	static func | (lhs: Parser, rhs: Parser) -> Parser {
		return lhs.or(rhs)
    }
	
	static postfix func <+> (parser: Parser) -> Parser {
		return parser.plus()
	}
	
	static postfix func <*> (parser: Parser) -> Parser {
		return parser.star()
	}
	
	static prefix func ! (parser: Parser) -> Parser {
		return parser.not()
	}
}
