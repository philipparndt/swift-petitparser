//
//  Functions.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-18.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

public class Functions {
    public class func nthOfList<T>(_ index: Int) -> ([T]) -> T {
        return { list in index < 0 ? list[list.count + index] : list[index]}
    }
    
    public class func permutationOfList(_ indexes: [Int]) -> ([Any]) -> [Any] {
        return { list in
            var result: [Any] = []
            for index in indexes {
                result.append(list[index < 0 ? list.count + index : index])
            }
            return result
        }
    }
    
    public class func separateByUnpack() -> ([Any]) -> [Any] {
        return { input in
            var result: [Any] = []
            
            result.append(input[0])
            
            if input.count > 1 {
                if let elements = input[1] as? [[Any]] {
                    for child in elements {
                        for inner in child {
                            result.append(inner)
                        }
                    }
                }
            }

            return result
        }
    }
    
    public class func delimitedByUnpack() -> ([Any]) -> [Any] {
        return { input in
            var result: [Any] = []
            
            if let elements = input[0] as? [Any] {
                 for child in elements {
                    result.append(child)
                }
            }
            
            if input.count > 1 {
                let other = input[1]
                if !(other is NSNull) {
                    result.append(other)
                }
            }
            
            return result
        }
    }
    
}
