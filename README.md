PetitParser for Swift
=====================

[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Grammars for programming languages are traditionally specified statically. They are hard to compose and reuse due to ambiguities that inevitably arise. PetitParser combines ideas from scannnerless parsing, parser combinators, parsing expression grammars and packrat parsers to model grammars and parsers as objects that can be reconfigured dynamically.

This library is based on [java-petitparser](https://github.com/petitparser/java-petitparser) from Lukas Renggli.
It has been adapted to Swift mainly as coding kata.


Installation
------------

- Swift package to be done
- CocoaPod to be done

Tutorial
--------

### Writing a Simple Grammar

Writing grammars with PetitParser is simple as writing Swift code. For example, to write a grammar that can parse identifiers that start with a letter followed by zero or more letter or digits is defined as follows:

We use the following import and type alias for all examples:
```swift
import swift_petitparser
typealias CP = CharacterParser
typealias SP = StringParser
```

```swift
class Example {
  init() {
    let id = CP.letter().seq(CP.letter().or(CP.digit()).star())
    ...
  }
}
```

If you look at the object `id` in the debugger, you'll notice that the code above builds a tree of parser objects:

- `SequenceParser`: This parser accepts a sequence of parsers.
  - `CharacterParser`: This parser accepts a single letter.
  - `PossessiveRepeatingParser`: This parser accepts zero or more times another parser.
    - `ChoiceParser`: This parser accepts a single word character.
      - `CharacterParser`: This parser accepts a single letter.
      - `CharacterParser`: This parser accepts a single digit.

### Parsing Some Input

To actually parse a `String` we can use the method `Parser#parse(String)`:

```swift
let id1 = id.parse("yeah")
let id2 = id.parse("f12")
```

The method `String` returns `Result`, which is either an instance of `Success` or `Failure`. In both examples above we are successful and can retrieve the parse result using `Success#get()`:

```swift
print(id1.get()!)  // ["y", ["e", "a", "h"]]
print(id2.get()!)  // ["f", ["1", "2"]]
```

While it seems odd to get these nested arrays with characters as a return value, this is the default decomposition of the input into a parse tree. We'll see in a while how that can be customized.

If we try to parse something invalid we get an instance of `Failure` as an answer and we can retrieve a descriptive error message using `Failure#getMessage()`:

```swift
let text = "123"
let id3 = id.parse(text)
print(id3.message!)                         // "letter expected"
print(id3.position.utf16Offset(in: text))   // 0
```

Trying to retrieve the parse result by calling `Failure#get()` will return an `nil` optional. `Result#isSuccess()` and `Result#isFailure()` can be used to decide if the parse was successful.

If you are only interested if a given string matches or not you can use the helper method `Parser#accept(String)`:

```swift
print(id.accept("foo"))  // true
print(id.accept("123"))  // false
```

### Different Kinds of Parsers

PetitParser provide a large set of ready-made parser that you can compose to consume and transform arbitrarily complex languages. The terminal parsers are the most simple ones. We've already seen a few of those:

- `CharacterParser.of("a")` parses the character _a_.
- `StringParser.of("abc")` parses the string _abc_.
- `CharacterParser.any()` parses any character.
- `CharacterParser.digit()` parses any digit from _0_ to _9_.
- `CharacterParser.letter()` parses any letter from _a_ to _z_ and _A_ to _Z_.
- `CharacterParser.word()` parses any letter or digit.

Many other parsers are available in `CharacterParser` and `StringParser`.

So instead of using the letter and digit predicate, we could have written our identifier parser like this:

```swift
let id = CP.letter().seq(CP.word().star())
```

The next set of parsers are used to combine other parsers together:

- `p1.seq(p2)` parses `p1` followed by `p2` (sequence).
- `p1.or(p2)` parses `p1`, if that doesn't work parses `p2` (ordered choice).
- `p.star()` parses `p` zero or more times.
- `p.plus()` parses `p` one or more times.
- `p.optional()` parses `p`, if possible.
- `p.and()` parses `p`, but does not consume its input.
- `p.not()` parses `p` and succeed when p fails, but does not consume its input.
- `p.end()` parses `p` and succeed at the end of the input.

To attach an action or transformation to a parser we can use the following methods:

- `p.map { somthing_with_$0 }` performs the transformation given the function.
- `p.pick(n)` returns the `n`-th element of the list `p` returns.
- `p.flatten()` creates a string from the result of `p`.
- `p.token()` creates a token from the result of `p`.
- `p.trim()` trims whitespaces before and after `p`.

To return a string of the parsed identifier, we can modify our parser like this:

```swift
let id_b = CP.letter().seq(CP.word().star()).flatten()
print(id_b.parse("yeah").get()!) // yeah
```

To conveniently find all matches in a given input string you can use `Parser#matchesSkipping(String)`:

```swift
let id = CP.letter().seq(CP.word().star()).flatten()
let matches: [String] = id.matchesSkipping("foo 123 bar4")
print(matches)  // ["foo", "bar4"]
```

These are the basic elements to build parsers. There are a few more well documented and tested factory methods in the `Parser` class. If you want, browse their documentation and tests.

### Writing a More Complicated Grammar

Now we are able to write a more complicated grammar for evaluating simple arithmetic expressions. Within a file we start with the grammar for a number (actually an integer):

```swift
let number = CP.digit().plus().flatten().trim()
    .map { (d: String) -> Int in Int(d)! }

print(number.parse("123").get()!) // 123
```

Then we define the productions for addition and multiplication in order of precedence. Note that we instantiate the productions with undefined parsers upfront, because they recursively refer to each other. Later on we can resolve this recursion by setting their reference:

```swift
let term = SettableParser.undefined()
let prod = SettableParser.undefined()
let prim = SettableParser.undefined()

term.set(prod.seq(CP.of("+").trim()).seq(term)
    .map { (nums: [Any]) -> Int in (nums[0] as! Int) + (nums[2] as! Int) }
    .or(prod))

prod.set(prim.seq(CP.of("*").trim()).seq(prod)
    .map { (nums: [Any]) -> Int in (nums[0] as! Int) * (nums[2] as! Int) }
    .or(prim))

prim.set((CP.of("(").trim().seq(term).seq(CP.of(")").trim()))
    .map { (nums: [Any]) -> Int in nums[1] as! Int }
    .or(NumbersParser.int()))
```

To make sure that our parser consumes all input we wrap it with the `end()` parser into the start production:

```swift
let start = term.end()
```

That's it, now we can test our parser and evaluator:

```swift
print(start.parse("1 + 2 * 3").get()!)  // 7
print(start.parse("(1 + 2) * 3").get()!)  // 9
```

As an exercise we could extend the parser to also accept negative numbers and floating point numbers, not only integers. Furthermore it would be useful to support subtraction and division as well. All these features
can be added with a few lines of PetitParser code.

### Using the Expression Builder

Writing such expression parsers is pretty common and can be quite tricky to get right. To simplify things, PetitParser comes with a builder that can help you to define such grammars easily. It supports the definition of operator precedence; and prefix, postfix, left- and right-associative operators.

The following code creates the empty expression builder:

```swift
let builder = ExpressionBuilder()
```

Then we define the operator-groups in descending precedence. The highest precedence are the literal numbers themselves. This time we accept floating point numbers, not just integers. In the same group we add support for parenthesis:

```swift
builder.group()
    .primitive(NumbersParser.double())
    .wrapper(CP.of("(").trim(), CP.of(")").trim(), { (nums: [Any]) -> Any in nums[1] })
```

Then come the normal arithmetic operators. Note, that the action blocks receive both, the terms and the parsed operator in the order they appear in the parsed input:

```swift
// negation is a prefix operator
builder.group()
.prefix(CP.of("-").trim(), { (nums: [Any]) -> Double in
    -(nums[1] as! Double)
})

// power is right-associative
builder.group()
.right(CP.of("^").trim(), { (nums: [Any]) -> Double in
    pow((nums[0] as! Double), (nums[2] as! Double))
})

// multiplication and addition are left-associative
builder.group()
.left(CP.of("*").trim(), { (nums: [Any]) -> Double in
    (nums[0] as! Double) * (nums[2] as! Double)
})
.left(CP.of("/").trim(), { (nums: [Any]) -> Double in
    (nums[0] as! Double) / (nums[2] as! Double)
})

builder.group()
.left(CP.of("+").trim(), { (nums: [Any]) -> Double in
    (nums[0] as! Double) + (nums[2] as! Double)
})
.left(CP.of("-").trim(), { (nums: [Any]) -> Double in
    (nums[0] as! Double) - (nums[2] as! Double)
})
```

Finally we can build the parser:

```swift
let parser = builder.build().end()
```

After executing the above code we get an efficient parser that correctly
evaluates expressions like:

```java
parser.parse("-8").get()!    // -8
parser.parse("1+2*3").get()! // 7
parser.parse("1*2+3").get()! // 5
parser.parse("8/4/2").get()! // 1
parser.parse("2^2^3").get()! // 256
```

You can find this example as test case here: [ExamplesTest.java](src/Tests/ExamplesTest.swift)

Misc
----

### History

PetitParser was originally implemented by Lukas Renggli in 
 - [Smalltalk](http://scg.unibe.ch/research/helvetia/petitparser).
 - [Java](https://github.com/petitparser/java-petitparser) and 
 - [Dart](https://github.com/petitparser/dart-petitparser). 
 
 and adapted to Swift by Philipp Arndt
 - [Swift](https://github.com/philipparndt/swift-petitparser)
  
 The implementations are very similar in their API and the supported features. If possible, the implementations adopt best practises of the target language.

### Ports

- [Dart](https://github.com/petitparser/dart-petitparser)
- [PHP](https://github.com/mindplay-dk/petitparserphp)
- [Smalltalk](http://scg.unibe.ch/research/helvetia/petitparser)
- [TypeScript](https://github.com/mindplay-dk/petitparser-ts)
- [Swift](https://github.com/philipparndt/swift-petitparser)

### License

The MIT License, see [LICENSE](LICENSE).
