@def title = "Learn Functional Programming by writing a Scheme in Haskell"
@def rss =  "Learn Functional Programming by writing a Scheme in Haskell"
@def published = "28 September 2019"
@def tags = ["functional-programming", "haskell", "lisp", "yasih"]

{{post_header}}

## How to make your first functional programming language. A book review.

After taking an introductory functional programming course last year I have decided to dive into Functional Programming in a challenging way.

At the beginning of the summer I've asked an experienced friend some ideas for a summer project. He suggested me to implement **R5RS Scheme** (Revised(5) Report on the Algorithmic Language Scheme) in Haskell. Scheme is called a dialect of LISP (**LI**st **PR**ocessor), a family of programming languages with a long history, famous for its fully parenthesized [prefix notation](https://en.wikipedia.org/wiki/Polish_notation). LISP  showed computer scientists in the 60s the importance of [λ (lambda) calculus](https://en.wikipedia.org/wiki/Lambda_calculus) and was originally specified in 1958 by John McCarthy, one of the founders of the Stanford AI Laboratory.

I've decided to call my Scheme implementation **yasih**, or **Y**et **A**nother **S**cheme **I**n **H**askell, since implementing a Scheme in Haskell is a popular exercise alongwise Computer Scientists. You can find the code in the [yasih repository](https://github.com/0x0f0f0f/yasih) on my GitHub profile.
 
At the time I only knew a little bit of OCaML and had some basic knowledge about λ-calculus and LISP, but I was itching for more knowledge about the internals and the history of functional programming. After a bit of googling I've stumbled into the excellent book [Write Yourself a Scheme in 48 Hours](https://en.wikibooks.org/wiki/Write_Yourself_a_Scheme_in_48_Hours/) and started diving into it.

The book is raw, it was refined by the WikiBooks community after the original version was open sourced, hence it is still incomplete. Each chapter explains the interpreter code step by step and also presents you with some exercises. At the beginning, it goes straight to parsing and assumes that you have some (basic) functional programming background.

Some Haskell concepts aren't explained clearly, while Scheme concepts are explained in much more detail. I had to do a lot of googling while reading each chapter. I also followed the [MIT R5RS spec](https://groups.csail.mit.edu/mac/ftpdir/scheme-reports/r5rs-html/r5rs_toc.html) and the [Guile Scheme reference manual](https://www.gnu.org/software/guile/docs/docs-1.6/guile-ref/R5RS-Index.html). [Guile](https://www.gnu.org/software/guile/) is the official scripting language of the GNU project and is a really great and fast implementation of the Scheme language. I've used it in parallel to my Scheme to test the correctness of the primitives I've implemented in my Scheme.

A simple LISP interpreter is composed by 3 components:

The first one, the **parser** is the section of interpreter that is responsible of reading each character, line-by-line, of a text file received in input (the program) and transform it into an **AST** (Abstract Syntax Tree). The parser also performs some syntactical correctness checks.
Here's an example of parsing a typical LISP parenthesized expression using the Parsec parser combinator library in Haskell:
```haskell
parseExpr :: Parser LispVal
parseExpr = do
    expr <- try parseComplex
        <|> try parseRatio
        <|> try parseFloat
        <|> try parseNumber
        <|> try parseAtom
        <|> parseString
        <|> try parseBool
        <|> try parseCharacter
        <|> try parseQuoted
        <|> try parseQuasiQuoted
        <|> try parseUnQuote
        <|> try parseVector
        <|> try parseParens
    skipMany parseComment
    return expr
```

The **AST** then gets evalauted by the **Evaluator**. The **Evaluator** receives in input an **AST** from the parser, executes semantical correctness checks (malformed forms, wrong argument numbers, unbound variables) and then recursively applies form evaluation and function calls, "executing" the AST expression and returning a value. Evaluation steps in λ-calculus are called β-reduction (applying functions to their arguments) and η-conversion (two functions are the same if and only if they give the same result for all arguments).

(The [April 1985 issue](https://www.flickr.com/photos/71827087@N00/124183635/) of "bit", a Japanese computer science magazine, which an introduction to Common Lisp.)

![Bit 1985 Cover](/assets/images/bitcover.jpg)

An interesting fact about the classical untyped λ-calculus is that it provides a [fixed-point combinator](https://en.wikipedia.org/wiki/Fixed-point_combinator) called an **Y-Combinator** that can be used to implement [Curry's Paradox](https://en.wikipedia.org/wiki/Curry%27s_paradox). It was first implemented by the logician **Haskell Curry** (which Haskell took its name from).

Here's the Y-Combinator in pure lambda calculus notation. You can read more about [Recursion in λ-calculus](https://sookocheff.com/post/fp/recursive-lambda-functions/).
```
λf.(λx.(f (x x)) λx.(f (x x)))
```

Here's the Y-Combinator in the Scheme language
```lisp
(lambda (f) ((lambda (g) (g g)) 
    (lambda (g) (f (lambda a (apply (g g) a))))))) 
```

From Wikipedia: "Applied to a function with one variable the Y combinator usually does not terminate. More interesting results are obtained by applying the Y combinator to functions of two or more variables. The second variable may be used as a counter, or index. The resulting function behaves like a while or a for loop in an imperative language.

Used in this way the Y combinator implements simple recursion. In the lambda calculus it is not possible to refer to the definition of a function in a function body. Recursion may only be achieved by passing in a function as a parameter. The Y combinator demonstrates this style of programming."

(Fun fact: [Hacker News](https://news.ycombinator.com/) is run by Paul Graham's investment fund and startup incubator, Y Combinator, that takes the name from Curry's paradoxical Y-Combinator)

The final part of the interpreter, the **REPL** (Read Eval Print Loop) is the glue between the user and the interpreter. It is a simple program that reads line by line from a file or a terminal interface and evaluates each statement, prints a result and loops back to reading.

Writing and making the evaluator was (and still is) the hardest part of making yasih Scheme. While testing a simple program, I've encountered a cryptical error:

```
unbound variable: if
```

After hours of debugging I've discovered that the error was originating from the fact that I was mishandling evaluation of the `if` form, and I was lacking an `eval` pattern matching case to evaluate an `if` expression without the `else` branch.

**yasih** is not ready for production at all. On the roadmap there's finishing implementing the R5RS standard, which includes adding `defmacro`, hygienic macros and some fixes related to character and REPL line parsing.
Here are some of the first examples I tested as soon as yasih reached a working status.

Fibonacci Number
```lisp
(define (fib-rec n)
  (if (< n 2)
      n
      (+ (fib-rec (- n 1))
         (fib-rec (- n 2)))))
```

Hanoi Tower Algorithm
```lisp
(define (hanoi n a b c)
  (if (> n 0)
    (begin
      (hanoi (- n 1) a c b)
      (display "Move disk from pole ")
      (display a)
      (display " to pole ")
      (display b)
      (newline)
      (hanoi (- n 1) c b a))))

(hanoi 4 1 2 3)
```
