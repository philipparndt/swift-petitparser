//
//  CharacterRange.swift
//  swift-petitparser
//
//  Created by Philipp Arndt on 2019-12-19.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation

class CharacterRange {
    let start: Character
    let stop: Character
    
    init(_ start: Character, _ stop: Character) {
        self.start = start
        self.stop = stop
    }
    
    class func toCharacterPredicate(_ ranges: [CharacterRange]) -> CharacterPredicate {
        // 1. sort the ranges
        var sortedRanges = ranges
        sortedRanges.sort { return $0.start < $1.start || $0.stop < $1.stop }
        
        // 2. merge adjacent or overlapping ranges
        var mergedRanges: [CharacterRange] = []
        
        for thisRange in sortedRanges {
            if mergedRanges.isEmpty {
                mergedRanges.append(thisRange)
            }
            else {
                let lastRange = mergedRanges.last!
                if lastRange.stop.asciiValue! + 1 >= thisRange.start.asciiValue! {
                    mergedRanges[mergedRanges.count - 1] = CharacterRange(lastRange.start, thisRange.stop)
                }
                else {
                    mergedRanges.append(thisRange)
                }
            }
            
        }
        
        // 3. build the best resulting predicates
        if mergedRanges.isEmpty {
            return CharacterPredicates.none()
        }
        else if mergedRanges.count == 1 {
            let characterRange = mergedRanges[0]
            
            return characterRange.start == characterRange.stop ?
            CharacterPredicates.of(characterRange.start) :
            CharacterPredicates.range(characterRange.start, characterRange.stop)
        }
        else {
            var starts: [Character] = []
            var stops: [Character] = []
            for range in mergedRanges {
                starts.append(range.start)
                stops.append(range.stop)
            }
            return CharacterPredicates.ranges(starts, stops)
        }
    }
}
