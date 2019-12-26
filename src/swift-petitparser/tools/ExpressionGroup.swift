//
//  ExpressionGroup.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-20.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public struct ExpressionResult {
    let op: Any
    let action: (Any) -> Any
}

public class ExpressionGroup {
    let loopback: Parser
    
    var primitives: [Parser] = []
    var wrappers: [Parser] = []
    var prefix: [Parser] = []
    var postfix: [Parser] = []
    var right: [Parser] = []
    var left: [Parser] = []
    
    init(_ loopback: Parser) {
        self.loopback = loopback
    }
    
    func buildChoice(_ parsers: [Parser]) -> Parser {
        buildChoice(parsers, FailureParser("otherwise"))
    }
    
    func buildChoice(_ parsers: [Parser], _ otherwise: Parser) -> Parser {
        if parsers.isEmpty {
            return otherwise
        }
        else if parsers.count == 1 {
            return parsers[0]
        }
        else {
            return ChoiceParser(parsers)
        }
    }
    
    public func build(_ inner: Parser) -> Parser {
      return buildLeft(buildRight(buildPostfix(buildPrefix(buildWrapper(buildPrimitive(inner))))))
    }
}

extension ExpressionGroup {
    @discardableResult public func primitive(_ parser: Parser) -> ExpressionGroup {
        primitives.append(parser)
        return self
    }
    
    @discardableResult public func primitive<A, B>(_ parser: Parser, _ action: @escaping (A) -> B) -> ExpressionGroup {
        primitives.append(parser.map(action))
        return self
    }
    
    func buildPrimitive(_ inner: Parser) -> Parser {
        return buildChoice(primitives, inner)
    }
}

extension ExpressionGroup {
    @discardableResult public func wrapper(_ left: Parser, _ right: Parser) -> ExpressionGroup {
        wrappers.append(SequenceParser(left, loopback, right))
        return self
    }
    
    @discardableResult public func wrapper<A, B>(_ left: Parser, _ right: Parser, _ action: @escaping (A) -> B) -> ExpressionGroup {
        wrappers.append(SequenceParser(left, loopback, right).map(action))
        return self
    }
    
    func buildWrapper(_ inner: Parser) -> Parser {
        var choices = wrappers
        choices.append(inner)
        return buildChoice(choices, inner)
    }
}

extension ExpressionGroup {
    @discardableResult public func prefix(_ parser: Parser) -> ExpressionGroup {
        prefix.append(parser.map { ExpressionResult(op: $0, action: { $0 }) })
        return self
    }

    @discardableResult public func prefix<A, B>(_ parser: Parser, _ action: @escaping (A) -> B) -> ExpressionGroup {
        prefix.append(parser.map { ExpressionResult(op: $0, action: { action($0 as! A) }) })
        return self
    }

    func buildPrefix(_ inner: Parser) -> Parser {
        if prefix.isEmpty {
            return inner
        }
        else {
            return SequenceParser(buildChoice(prefix).star(), inner)
                .map(mapPrefix)
        }
    }
    
    private func mapPrefix(_ tuple: [Any]) -> Any {
        var value = tuple[1]
        var tuples = tuple[0] as! [ExpressionResult]
        tuples.reverse()
        for result in tuples {
            value = result.action([result.op, value])
        }
        return value
    }
}

extension ExpressionGroup {
    @discardableResult public func postfix(_ parser: Parser) -> ExpressionGroup {
        postfix.append(parser.map { ExpressionResult(op: $0, action: { $0 }) })
        return self
    }

    @discardableResult public func postfix<A, B>(_ parser: Parser, _ action: @escaping (A) -> B) -> ExpressionGroup {
        postfix.append(parser.map { ExpressionResult(op: $0, action: { action($0 as! A) }) })
        return self
    }

    func buildPostfix(_ inner: Parser) -> Parser {
        if postfix.isEmpty {
            return inner
        }
        else {
            return SequenceParser(inner, buildChoice(postfix).star())
                .map(mapPostfix)
        }
    }
    
    private func mapPostfix(_ tuple: [Any]) -> Any {
        var value = tuple[0]
        let tuples = tuple[1] as! [ExpressionResult]
        for result in tuples {
            value = result.action([value, result.op])
        }
        return value
    }
}

extension ExpressionGroup {
    @discardableResult public func right(_ parser: Parser) -> ExpressionGroup {
        right.append(parser.map { ExpressionResult(op: $0, action: { $0 }) })
        return self
    }

    @discardableResult public func right<A, B>(_ parser: Parser, _ action: @escaping (A) -> B) -> ExpressionGroup {
        right.append(parser.map { ExpressionResult(op: $0, action: { action($0 as! A) }) })
        return self
    }
    
    func buildRight(_ inner: Parser) -> Parser {
        if right.isEmpty {
            return inner
        }
        else {
            return inner.separatedBy(buildChoice(right))
                .map(mapRight)
        }
    }
    
    private func mapRight(_ innerSequence: [Any]) -> Any {
        var result = innerSequence.last!
        
        for i in stride(from: innerSequence.count - 2, to: 0, by: -2) {
            let expressionResult = innerSequence[i] as! ExpressionResult
            result = expressionResult.action([innerSequence[i - 1], expressionResult.op, result])
        }
  
        return result
    }
}

extension ExpressionGroup {
    @discardableResult public func left(_ parser: Parser) -> ExpressionGroup {
        left.append(parser.map { ExpressionResult(op: $0, action: { $0 }) })
        return self
    }

    @discardableResult public func left<A, B>(_ parser: Parser, _ action: @escaping (A) -> B) -> ExpressionGroup {
        left.append(parser.map { ExpressionResult(op: $0, action: { action($0 as! A) }) })
        return self
    }
    
    func buildLeft(_ inner: Parser) -> Parser {
        if left.isEmpty {
            return inner
        }
        else {
            return inner.separatedBy(buildChoice(left))
                .map(mapLeft)
        }
    }
    
    private func mapLeft(_ innerSequence: [Any]) -> Any {
        var result = innerSequence[0]
        
        for i in stride(from: 1, to: innerSequence.count, by: 2) {
            let expressionResult = innerSequence[i] as! ExpressionResult
            result = expressionResult.action([result, expressionResult.op, innerSequence[i + 1]])
        }
        
        return result
    }
}
