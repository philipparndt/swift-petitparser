//
//  Tracer.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-23.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public protocol TraceConsumer {
    func accept(_ event: TraceEvent)
}

public protocol ParentClosure {
    func setParentClosure(_ event: TraceEvent?)
    func getParentClosure() -> TraceEvent?
}

public class Tracer: ParentClosure {
    
    let consumer: TraceConsumer
    var parentClosure: TraceEvent?

    init(_ consumer: TraceConsumer) {
        self.consumer = consumer
    }

    public func setParentClosure(_ event: TraceEvent?) {
        parentClosure = event
    }
    
    public func getParentClosure() -> TraceEvent? {
        return parentClosure
    }
    
    public class func on(_ source: Parser, consumer: TraceConsumer) -> Parser {
        let tracer = Tracer(consumer)
        return Mirror.of(source)
            .transform(tracer.transform)
    }
    
    func transform(parser: Parser) -> Parser {
        return parser.callCC(TracerContinuationHandler(parser, consumer, self))
    }
}

class TracerContinuationHandler: ContinuationHandler {
    let parser: Parser
    let consumer: TraceConsumer
    let parentClosure: ParentClosure
        
    init(_ parser: Parser, _ consumer: TraceConsumer, _ parentClosure: ParentClosure) {
        self.parser = parser
        self.consumer = consumer
        self.parentClosure = parentClosure
    }
    
    public func apply(_ continuation: @escaping (Context) -> Result, _ context: Context) -> Result {
        let parent = self.parentClosure.getParentClosure()
        let enter = TraceEvent(TraceEventType.enter, parent, parser, context)
        consumer.accept(enter)
        parentClosure.setParentClosure(enter)

        let result = continuation(context)
        parentClosure.setParentClosure(parent)
        consumer.accept(TraceEvent(TraceEventType.exit, parent, parser, result))
        return result
    }
}

public class TraceArrayConsumer: TraceConsumer {
    var events: [TraceEvent] = []

    public func accept(_ event: TraceEvent) {
        events.append(event)
    }
}

/**
 * The trace event type differentiating between activation and return.
 */
public enum TraceEventType {
    case enter
    case exit
}

/**
 * The trace event holding all relevant data.
 */
public class TraceEvent {

    let type: TraceEventType
    let parent: TraceEvent?
    let parser: Parser
    let context: Context

    init(_ type: TraceEventType, _ parent: TraceEvent?, _ parser: Parser, _ context: Context) {
        self.type = type
        self.parent = parent
        self.parser = parser
        self.context = context
    }
    
    func getLevel() -> Int {
        return parent.map { $0.getLevel() + 1 } ?? 0
    }
}

extension TraceEvent: CustomStringConvertible {
    public var description: String {
        let indent = String(repeating: "  ", count: getLevel())
        let type = TraceEventType.enter == self.type ? "\(parser)" : "\(context)"
        return "\(indent)\(type)"
    }
}
