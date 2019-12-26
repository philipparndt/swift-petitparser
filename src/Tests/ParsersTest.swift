//
//  ParsersTest.swift
//  Tests
//
//  Created by Philipp Arndt on 2019-12-20.
//  Copyright © 2019 petitparser. All rights reserved.
//

import Foundation
import XCTest
@testable import swift_petitparser

// swiftlint:disable type_body_length nesting
class ParsersTests: XCTestCase {
    
    func char(_ c: Character) -> Character {
        return c
    }

    func testAnd() {
        let parser = CP.of("a").and()
        Assert.assertSuccess(parser, "a", char("a"), 0)
        Assert.assertFailure(parser, "b", "'a' expected")
        Assert.assertFailure(parser, "")
    }
    
    func testChoice2() {
        let parser = CP.of("a").or(CP.of("b"))
        Assert.assertSuccess(parser, "a", char("a"))
        Assert.assertSuccess(parser, "b", char("b"))
        Assert.assertFailure(parser, "c")
        Assert.assertFailure(parser, "")
    }
    
    func testChoice3() {
        let parser = CP.of("a").or(CP.of("b")).or(CP.of("c"))
        Assert.assertSuccess(parser, "a", char("a"))
        Assert.assertSuccess(parser, "b", char("b"))
        Assert.assertSuccess(parser, "c", char("c"))
        Assert.assertFailure(parser, "d")
        Assert.assertFailure(parser, "")
    }
    
    func testEndOfInput() {
        let parser = CP.of("a").end()
        Assert.assertFailure(parser, "", "'a' expected")
        Assert.assertSuccess(parser, "a", char("a"))
        Assert.assertFailure(parser, "aa", 1, "end of input expected")
    }
    
    func testSettable() {
        let parser = CP.of("a").settable()
        Assert.assertSuccess(parser, "a", char("a"))
        Assert.assertFailure(parser, "b", 0, "'a' expected")
        
        parser.set(CP.of("b"))
        Assert.assertSuccess(parser, "b", char("b"))
        Assert.assertFailure(parser, "a", 0, "'b' expected")
    }
    
    func testFlatten1() {
        let parser = CP.digit().repeated(2, RepeatingParser.UNBOUNDED).flatten()
        Assert.assertFailure(parser, "", 0, "digit expected")
        Assert.assertFailure(parser, "a", 0, "digit expected")
        Assert.assertFailure(parser, "1", 1, "digit expected")
        Assert.assertFailure(parser, "1a", 1, "digit expected")
        Assert.assertSuccess(parser, "12", "12")
        Assert.assertSuccess(parser, "123", "123")
        Assert.assertSuccess(parser, "1234", "1234")
    }

    func testFlatten2() {
        let parser = CP.digit().repeated(2, RepeatingParser.UNBOUNDED)
            .flatten("gimme a number")
        Assert.assertFailure(parser, "", 0, "gimme a number")
        Assert.assertFailure(parser, "a", 0, "gimme a number")
        Assert.assertFailure(parser, "1", 0, "gimme a number")
        Assert.assertFailure(parser, "1a", 0, "gimme a number")
        Assert.assertSuccess(parser, "12", "12")
        Assert.assertSuccess(parser, "123", "123")
        Assert.assertSuccess(parser, "1234", "1234")
    }
    
    func testMap() {
        let parser = CP.digit()
        .map { (c: Character) -> Int in Int("\(c)") ?? -1 }
        Assert.assertSuccess(parser, "1", 1)
        Assert.assertSuccess(parser, "4", 4)
        Assert.assertSuccess(parser, "9", 9)
        Assert.assertFailure(parser, "")
        Assert.assertFailure(parser, "a")
    }
    
    func testPick() {
        let parser = CP.digit().seq(CP.letter()).pick(1)
        Assert.assertSuccess(parser, "1a", char("a"))
        Assert.assertSuccess(parser, "2b", char("b"))
        Assert.assertFailure(parser, "")
        Assert.assertFailure(parser, "1", 1, "letter expected")
        Assert.assertFailure(parser, "12", 1, "letter expected")
    }
    
    func testPickLast() {
        let parser = CP.digit().seq(CP.letter()).pick(-1)
        Assert.assertSuccess(parser, "1a", char("a"))
        Assert.assertSuccess(parser, "2b", char("b"))
        Assert.assertFailure(parser, "")
        Assert.assertFailure(parser, "1", 1, "letter expected")
        Assert.assertFailure(parser, "12", 1, "letter expected")
    }

    func testPermute() {
        let parser = CP.digit().seq(CP.letter()).permute(1, 0)
        Assert.assertSuccess(parser, "1a", [char("a"), char("1")])
        Assert.assertSuccess(parser, "2b", [char("b"), char("2")])
        Assert.assertFailure(parser, "")
        Assert.assertFailure(parser, "1", 1, "letter expected")
        Assert.assertFailure(parser, "12", 1, "letter expected")
    }

    func testPermuteLast() {
        let parser = CP.digit().seq(CP.letter()).permute(-1, 0)
        Assert.assertSuccess(parser, "1a", [char("a"), char("1")])
        Assert.assertSuccess(parser, "2b", [char("b"), char("2")])
        Assert.assertFailure(parser, "")
        Assert.assertFailure(parser, "1", 1, "letter expected")
        Assert.assertFailure(parser, "12", 1, "letter expected")
    }
    
    func testNeg1() {
        let parser = CP.digit().neg()
        Assert.assertFailure(parser, "1", 0)
        Assert.assertFailure(parser, "9", 0)
        Assert.assertSuccess(parser, "a", char("a"))
        Assert.assertSuccess(parser, " ", char(" "))
        Assert.assertFailure(parser, "", 0)
    }
    
    func testNeg2() {
        let parser = CP.digit().neg("no digit expected")
        Assert.assertFailure(parser, "1", 0, "no digit expected")
        Assert.assertFailure(parser, "9", 0, "no digit expected")
        Assert.assertSuccess(parser, "a", char("a"))
        Assert.assertSuccess(parser, " ", char(" "))
        Assert.assertFailure(parser, "", 0, "no digit expected")
    }

    func testNeg3() {
        let parser = SP.of("foo").neg("no foo expected")
        Assert.assertFailure(parser, "foo", 0, "no foo expected")
        Assert.assertFailure(parser, "foobar", 0, "no foo expected")
        Assert.assertSuccess(parser, "f", char("f"))
        Assert.assertSuccess(parser, " ", char(" "))
    }

    func testNot() {
        let parser = CP.of("a").not("not a expected")
        Assert.assertFailure(parser, "a", "not a expected")
        Assert.assertSuccess(parser, "b", Assert.NULL, 0)
        Assert.assertSuccess(parser, "", Assert.NULL)
    }
    
    func testOptional() {
        let parser = CP.of("a").optional()
        Assert.assertSuccess(parser, "a", char("a"))
        Assert.assertSuccess(parser, "b", Assert.NULL, 0)
        Assert.assertSuccess(parser, "", Assert.NULL)
    }
    
    func testPlus() {
        let parser = CP.of("a").plus()
        Assert.assertFailure(parser, "", "'a' expected")
        Assert.assertSuccess(parser, "a", [char("a")])
        Assert.assertSuccess(parser, "aa", [char("a"), char("a")])
        Assert.assertSuccess(parser, "aaa", [char("a"), char("a"), char("a")])
    }
    
    func testPlusGreedy() {
        let parser = CP.word().plusGreedy(CharacterParser.digit())
        Assert.assertFailure(parser, "", 0, "letter or digit expected")
        Assert.assertFailure(parser, "a", 1, "digit expected")
        Assert.assertFailure(parser, "ab", 1, "digit expected")
        Assert.assertFailure(parser, "1", 1, "digit expected")
        Assert.assertSuccess(parser, "a1", [char("a")], 1)
        Assert.assertSuccess(parser, "ab1", [char("a"), char("b")], 2)
        Assert.assertSuccess(parser, "abc1", [char("a"), char("b"), char("c")], 3)
        Assert.assertSuccess(parser, "12", [char("1")], 1)
        Assert.assertSuccess(parser, "a12", [char("a"), char("1")], 2)
        Assert.assertSuccess(parser, "ab12", [char("a"), char("b"), char("1")], 3)
        Assert.assertSuccess(parser, "abc12", [char("a"), char("b"), char("c"), char("1")], 4)
        Assert.assertSuccess(parser, "123", [char("1"), char("2")], 2)
        Assert.assertSuccess(parser, "a123", [char("a"), char("1"), char("2")], 3)
        Assert.assertSuccess(parser, "ab123", [char("a"), char("b"), char("1"), char("2")], 4)
        Assert.assertSuccess(parser, "abc123", [char("a"), char("b"), char("c"), char("1"), char("2")], 5)
    }
    
    func testPlusLazy() {
        let parser = CP.word().plusLazy(CharacterParser.digit())
        Assert.assertFailure(parser, "")
        Assert.assertFailure(parser, "a", 1, "digit expected")
        Assert.assertFailure(parser, "ab", 2, "digit expected")
        Assert.assertFailure(parser, "1", 1, "digit expected")
        Assert.assertSuccess(parser, "a1", [char("a")], 1)
        Assert.assertSuccess(parser, "ab1", [char("a"), char("b")], 2)
        Assert.assertSuccess(parser, "abc1", [char("a"), char("b"), char("c")], 3)
        Assert.assertSuccess(parser, "12", [char("1")], 1)
        Assert.assertSuccess(parser, "a12", [char("a")], 1)
        Assert.assertSuccess(parser, "ab12", [char("a"), char("b")], 2)
        Assert.assertSuccess(parser, "abc12", [char("a"), char("b"), char("c")], 3)
        Assert.assertSuccess(parser, "123", [char("1")], 1)
        Assert.assertSuccess(parser, "a123", [char("a")], 1)
        Assert.assertSuccess(parser, "ab123", [char("a"), char("b")], 2)
        Assert.assertSuccess(parser, "abc123", [char("a"), char("b"), char("c")], 3)
    }
    
    func testTimes() {
        let parser = CP.of("a").times(2)
        Assert.assertFailure(parser, "", 0, "'a' expected")
        Assert.assertFailure(parser, "a", 1, "'a' expected")
        Assert.assertSuccess(parser, "aa", [char("a"), char("a")])
        Assert.assertSuccess(parser, "aaa", [char("a"), char("a")], 2)
    }
    
    func testRepeat() {
        let parser = CP.of("a").repeated(2, 3)
        Assert.assertFailure(parser, "", "'a' expected")
        Assert.assertFailure(parser, "a", 1, "'a' expected")
        Assert.assertSuccess(parser, "aa", [char("a"), char("a")])
        Assert.assertSuccess(parser, "aaa", [char("a"), char("a"), char("a")])
        Assert.assertSuccess(parser, "aaaa", [char("a"), char("a"), char("a")], 3)
    }
    
//    func testRepeatMinError1() {
//        let _ = CP.of("a").repeated(-2, 5)
//    }
//
//    func testRepeatMinError2() {
//        let _ = CP.of("a").repeated(3, 5)
//    }
    
    func testRepeatUnbounded() {
        var list: [Character] = []
        var string = ""
        for _ in 0..<100000 {
            list.append("a")
            string += "a"
        }
        
        let parser = CP.of("a").repeated(2, RepeatingParser.UNBOUNDED)
        Assert.assertSuccess(parser, string, list)
    }
    
    func testRepeatGreedy() {
        let parser = CP.word().repeatGreedy(CP.digit(), 2, 4)
        Assert.assertFailure(parser, "", 0, "letter or digit expected")
        Assert.assertFailure(parser, "a", 1, "letter or digit expected")
        Assert.assertFailure(parser, "ab", 2, "digit expected")
        Assert.assertFailure(parser, "abc", 2, "digit expected")
        Assert.assertFailure(parser, "abcd", 2, "digit expected")
        Assert.assertFailure(parser, "abcde", 2, "digit expected")
        Assert.assertFailure(parser, "1", 1, "letter or digit expected")
        Assert.assertFailure(parser, "a1", 2, "digit expected")
        Assert.assertSuccess(parser, "ab1", [char("a"), char("b")], 2)
        Assert.assertSuccess(parser, "abc1", [char("a"), char("b"), char("c")], 3)
        Assert.assertSuccess(parser, "abcd1", [char("a"), char("b"), char("c"), char("d")], 4)
        Assert.assertFailure(parser, "abcde1", 2, "digit expected")
        Assert.assertFailure(parser, "12", 2, "digit expected")
        Assert.assertSuccess(parser, "a12", [char("a"), char("1")], 2)
        Assert.assertSuccess(parser, "ab12", [char("a"), char("b"), char("1")], 3)
        Assert.assertSuccess(parser, "abc12", [char("a"), char("b"), char("c"), char("1")], 4)
        Assert.assertSuccess(parser, "abcd12", [char("a"), char("b"), char("c"), char("d")], 4)
        Assert.assertFailure(parser, "abcde12", 2, "digit expected")
        Assert.assertSuccess(parser, "123", [char("1"), char("2")], 2)
        Assert.assertSuccess(parser, "a123", [char("a"), char("1"), char("2")], 3)
        Assert.assertSuccess(parser, "ab123", [char("a"), char("b"), char("1"), char("2")], 4)
        Assert.assertSuccess(parser, "abc123", [char("a"), char("b"), char("c"), char("1")], 4)
        Assert.assertSuccess(parser, "abcd123", [char("a"), char("b"), char("c"), char("d")], 4)
        Assert.assertFailure(parser, "abcde123", 2, "digit expected")
    }
    
//    func testRepeatGreedyUnbounded() {
//        var letter = ""
//        var listLetter: [Character] = []
//        
//        var digit = ""
//        var listDigit: [Character] = []
//
//        for _ in 0..<100000 {
//            letter += "a"
//            listLetter += "a"
//
//            digit += "1"
//            listDigit += "1"
//        }
//        
//        letter += "a"
//        digit += "1"
//
//        let parser = CP.word()
//            .repeatGreedy(CP.digit(), 2, RepeatingParser.UNBOUNDED);
//        Assert.assertSuccess(parser, letter, listLetter, listLetter.count)
//        Assert.assertSuccess(parser, digit, listDigit, listDigit.count)
//    }

    func testRepeatLazy() {
        let parser = CP.word().repeatLazy(CP.digit(), 2, 4)
        Assert.assertFailure(parser, "", 0, "letter or digit expected")
        Assert.assertFailure(parser, "a", 1, "letter or digit expected")
        Assert.assertFailure(parser, "ab", 2, "digit expected")
        Assert.assertFailure(parser, "abc", 3, "digit expected")
        Assert.assertFailure(parser, "abcd", 4, "digit expected")
        Assert.assertFailure(parser, "abcde", 4, "digit expected")
        Assert.assertFailure(parser, "1", 1, "letter or digit expected")
        Assert.assertFailure(parser, "a1", 2, "digit expected")
        Assert.assertSuccess(parser, "ab1", [char("a"), char("b")], 2)
        Assert.assertSuccess(parser, "abc1", [char("a"), char("b"), char("c")], 3)
        Assert.assertSuccess(parser, "abcd1", [char("a"), char("b"), char("c"), char("d")], 4)
        Assert.assertFailure(parser, "abcde1", 4, "digit expected")
        Assert.assertFailure(parser, "12", 2, "digit expected")
        Assert.assertSuccess(parser, "a12", [char("a"), char("1")], 2)
        Assert.assertSuccess(parser, "ab12", [char("a"), char("b")], 2)
        Assert.assertSuccess(parser, "abc12", [char("a"), char("b"), char("c")], 3)
        Assert.assertSuccess(parser, "abcd12", [char("a"), char("b"), char("c"), char("d")], 4)
        Assert.assertFailure(parser, "abcde12", 4, "digit expected")
        Assert.assertSuccess(parser, "123", [char("1"), char("2")], 2)
        Assert.assertSuccess(parser, "a123", [char("a"), char("1")], 2)
        Assert.assertSuccess(parser, "ab123", [char("a"), char("b")], 2)
        Assert.assertSuccess(parser, "abc123", [char("a"), char("b"), char("c")], 3)
        Assert.assertSuccess(parser, "abcd123", [char("a"), char("b"), char("c"), char("d")], 4)
        Assert.assertFailure(parser, "abcde123", 4, "digit expected")
    }
    
//    @Test
//     public void testRepeatLazyUnbounded() {
//       StringBuilder builder = new StringBuilder();
//       List<Character> list = new ArrayList<>();
//       for (int i = 0; i < 100000; i++) {
//         builder.append('a');
//         list.add('a');
//       }
//       builder.append("1111");
//       Parser parser = CharacterParser.word()
//           .repeatLazy(CharacterParser.digit(), 2, RepeatingParser.UNBOUNDED);
//       assertSuccess(parser, builder.toString(), list, list.size());
//     }
//
//     @Test
//     public void testSequence2() {
//       Parser parser = of('a').seq(of('b'));
//       assertSuccess(parser, "ab", Arrays.asList('a', 'b'));
//       assertFailure(parser, "");
//       assertFailure(parser, "x");
//       assertFailure(parser, "a", 1);
//       assertFailure(parser, "ax", 1);
//     }
//
//     @Test
//     public void testSequence3() {
//       Parser parser = of('a').seq(of('b')).seq(of('c'));
//       assertSuccess(parser, "abc", Arrays.asList('a', 'b', 'c'));
//       assertFailure(parser, "");
//       assertFailure(parser, "x");
//       assertFailure(parser, "a", 1);
//       assertFailure(parser, "ax", 1);
//       assertFailure(parser, "ab", 2);
//       assertFailure(parser, "abx", 2);
//     }
//
    
    func testStar() {
        let parser = CP.of("a").star()
        Assert.assertSuccess(parser, "", [])
        Assert.assertSuccess(parser, "a", [char("a")])
        Assert.assertSuccess(parser, "aa", [char("a"), char("a")])
        Assert.assertSuccess(parser, "aaa", [char("a"), char("a"), char("a")])
    }
    
    func testStarGreedy() {
        let parser = CP.word().starGreedy(CP.digit())
        Assert.assertFailure(parser, "", 0, "digit expected")
        Assert.assertFailure(parser, "a", 0, "digit expected")
        Assert.assertFailure(parser, "ab", 0, "digit expected")
        Assert.assertSuccess(parser, "1", Assert.EMPTY, 0)
        Assert.assertSuccess(parser, "a1", [char("a")], 1)
        Assert.assertSuccess(parser, "ab1", [char("a"), char("b")], 2)
        Assert.assertSuccess(parser, "abc1", [char("a"), char("b"), char("c")], 3)
        Assert.assertSuccess(parser, "12", [char("1")], 1)
        Assert.assertSuccess(parser, "a12", [char("a"), char("1")], 2)
        Assert.assertSuccess(parser, "ab12", [char("a"), char("b"), char("1")], 3)
        Assert.assertSuccess(parser, "abc12", [char("a"), char("b"), char("c"), char("1")], 4)
        Assert.assertSuccess(parser, "123", [char("1"), char("2")], 2)
        Assert.assertSuccess(parser, "a123", [char("a"), char("1"), char("2")], 3)
        Assert.assertSuccess(parser, "ab123", [char("a"), char("b"), char("1"), char("2")], 4)
        Assert.assertSuccess(parser, "abc123", [char("a"), char("b"), char("c"), char("1"), char("2")], 5)
    }

    func testStarLazy() {
       let parser = CP.word().starLazy(CP.digit())
       Assert.assertFailure(parser, "")
       Assert.assertFailure(parser, "a", 1, "digit expected")
       Assert.assertFailure(parser, "ab", 2, "digit expected")
       Assert.assertSuccess(parser, "1", Assert.EMPTY, 0)
       Assert.assertSuccess(parser, "a1", [char("a")], 1)
       Assert.assertSuccess(parser, "ab1", [char("a"), char("b")], 2)
       Assert.assertSuccess(parser, "abc1", [char("a"), char("b"), char("c")], 3)
       Assert.assertSuccess(parser, "12", Assert.EMPTY, 0)
       Assert.assertSuccess(parser, "a12", [char("a")], 1)
       Assert.assertSuccess(parser, "ab12", [char("a"), char("b")], 2)
       Assert.assertSuccess(parser, "abc12", [char("a"), char("b"), char("c")], 3)
       Assert.assertSuccess(parser, "123", Assert.EMPTY, 0)
       Assert.assertSuccess(parser, "a123", [char("a")], 1)
       Assert.assertSuccess(parser, "ab123", [char("a"), char("b")], 2)
       Assert.assertSuccess(parser, "abc123", [char("a"), char("b"), char("c")], 3)
     }

    func testToken() {
        let parser = CP.of("a").star().token().trim()
        let token: Token = parser.parse(" aa ").get()!
        XCTAssertEqual(1, token.start.utf16Offset(in: " aa "))
        XCTAssertEqual(3, token.stop.utf16Offset(in: " aa "))
//        Assert.assertEquals([char("a"), char("a")], token.<List<Character>>getValue()]
     }

     func testTrim() {
        let parser = CP.of("a").trim()
        Assert.assertSuccess(parser, "a", char("a"))
        Assert.assertSuccess(parser, " a", char("a"))
        Assert.assertSuccess(parser, "a ", char("a"))
        Assert.assertSuccess(parser, " a ", char("a"))
        Assert.assertSuccess(parser, "  a", char("a"))
        Assert.assertSuccess(parser, "a  ", char("a"))
        Assert.assertSuccess(parser, "  a  ", char("a"))
        Assert.assertFailure(parser, "", "'a' expected")
        Assert.assertFailure(parser, "b", "'a' expected")
        Assert.assertFailure(parser, " b", 1, "'a' expected")
        Assert.assertFailure(parser, "  b", 2, "'a' expected")
     }

    func testTrimCustom() {
        let parser = CP.of("a").trim(CP.of("*"))
        Assert.assertSuccess(parser, "a", char("a"))
        Assert.assertSuccess(parser, "*a", char("a"))
        Assert.assertSuccess(parser, "a*", char("a"))
        Assert.assertSuccess(parser, "*a*", char("a"))
        Assert.assertSuccess(parser, "**a", char("a"))
        Assert.assertSuccess(parser, "a**", char("a"))
        Assert.assertSuccess(parser, "**a**", char("a"))
        Assert.assertFailure(parser, "", "'a' expected")
        Assert.assertFailure(parser, "b", "'a' expected")
        Assert.assertFailure(parser, "*b", 1, "'a' expected")
        Assert.assertFailure(parser, "**b", 2, "'a' expected")
    }
    
    func testSeparatedBy() {
        let parser = CP.of("a").separatedBy(CP.of("b"))
        Assert.assertFailure(parser, "", "'a' expected")
        Assert.assertSuccess(parser, "a", [char("a")])
        Assert.assertSuccess(parser, "ab", [char("a")], 1)
        Assert.assertSuccess(parser, "aba", [char("a"), char("b"), char("a")])
        Assert.assertSuccess(parser, "abab", [char("a"), char("b"), char("a")], 3)
        Assert.assertSuccess(parser, "ababa", [char("a"), char("b"), char("a"), char("b"), char("a")])
        Assert.assertSuccess(parser, "ababab", [char("a"), char("b"), char("a"), char("b"), char("a")], 5)
    }

    func testDelimitedBy() {
        let parser = CP.of("a").delimitedBy(CP.of("b"))
        Assert.assertFailure(parser, "", "'a' expected")
        Assert.assertSuccess(parser, "a", [char("a")])
        Assert.assertSuccess(parser, "ab", [char("a"), char("b")])
        Assert.assertSuccess(parser, "aba", [char("a"), char("b"), char("a")])
        Assert.assertSuccess(parser, "abab", [char("a"), char("b"), char("a"), char("b")])
        Assert.assertSuccess(parser, "ababa", [char("a"), char("b"), char("a"), char("b"), char("a")])
        Assert.assertSuccess(parser, "ababab",
           [char("a"), char("b"), char("a"), char("b"), char("a"), char("b")])
    }

    func testContinuationDelegating() {
        struct Continuation: ContinuationHandler {
            func apply(_ continuation: (Context) -> Result, _ context: Context) -> Result {
                return continuation(context)
            }
        }
        
        let parser = CharacterParser.digit().callCC(Continuation())
        XCTAssertTrue(parser.parse("1").isSuccess())
        XCTAssertFalse(parser.parse("a").isSuccess())
    }
    
    func testContinuationRedirecting() {
        struct Continuation: ContinuationHandler {
            func apply(_ continuation: (Context) -> Result, _ context: Context) -> Result {
                return CP.letter().parseOn(context)
            }
        }
        
        let parser = CharacterParser.digit().callCC(Continuation())
        XCTAssertFalse(parser.parse("1").isSuccess())
        XCTAssertTrue(parser.parse("a").isSuccess())
    }

     func testContinuationResuming() {
        class Continuation: ContinuationHandler {
            var continuations: [(Context) -> Result] = []
            var contexts: [Context] = []
             
            func apply(_ continuation: @escaping (Context) -> Result, _ context: Context) -> Result {
                self.continuations.append(continuation)
                self.contexts.append(context)
                
                // we have to return something for now
                return context.failure("Abort")
            }
        }
        let continuation = Continuation()
        let parser = CP.digit().callCC(continuation)
        
        // execute the parser twice to collect the continuations
        XCTAssertFalse(parser.parse("1").isSuccess())
        XCTAssertFalse(parser.parse("a").isSuccess())
        
        // later we can execute the captured continuations
        XCTAssertTrue(continuation.continuations[0](continuation.contexts[0]).isSuccess())
        XCTAssertFalse(continuation.continuations[1](continuation.contexts[1]).isSuccess())
        
        // of course the continuations can be resumed multiple times
        XCTAssertTrue(continuation.continuations[0](continuation.contexts[0]).isSuccess())
        XCTAssertFalse(continuation.continuations[1](continuation.contexts[1]).isSuccess())
    }

    func testContinuationSuccessful() {
        struct Continuation: ContinuationHandler {
            func apply(_ continuation: (Context) -> Result, _ context: Context) -> Result {
                return context.success("Always succeed")
            }
        }
        
        let parser = CharacterParser.digit()
           .callCC(Continuation())
            
        XCTAssertTrue(parser.parse("1").isSuccess())
        XCTAssertTrue(parser.parse("a").isSuccess())
    }

    func testContinuationFailing() {
        struct Continuation: ContinuationHandler {
            func apply(_ continuation: (Context) -> Result, _ context: Context) -> Result {
                return context.failure("Always fail")
            }
        }
        
        let parser = CharacterParser.digit()
           .callCC(Continuation())
        
        XCTAssertFalse(parser.parse("1").isSuccess())
        XCTAssertFalse(parser.parse("a").isSuccess())
    }
    
    func testSequence() {
        let parser = SequenceParser(CP.digit(), CP.word())
        XCTAssertTrue(parser.parse("1a").isSuccess())
        XCTAssertFalse(parser.parse("a1").isSuccess())
    }
}
