//
//  StringPredicate.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-19.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class StringPredicate {
    var test: (String) -> Bool

    init(matcher: @escaping (String) -> Bool) {
        self.test = matcher
    }
}
