@def title = "Adding a macro parser to my Scheme implementation"
@def published = "31 October 2019"
@def tags = ["functional-programming", "haskell", "lisp", "yasih"]

{{post_header}}


Happy Halloween everybody, here's a little report on how I've added a
macro parser to [yasih](https://github.com/0x0f0f0f/yasih) (Yet Another Scheme in Haskell),
my own R5RS Scheme implementation written in Haskell.

At first I've had to define parsers for `quote`, `quasiquote`, and `unquote` and add them to the expression parser.
You can learn more about how scheme quoting works [in the MIT-scheme documentation](https://www.gnu.org/software/mit-scheme/documentation/mit-scheme-ref/Quoting.html).

```haskell
-- |Parse a Quoted Expression 'a
parseQuoted :: Parser LispVal
parseQuoted = do
    char '\''
    x <- parseExpr
    return $ List [Atom "quote", x]

-- |Parse a QuasiQuoted Expression
-- See https://schemers.org/Documents/Standards/R5RS/HTML/r5rs-Z-H-7.html#%_sec_4.2.6
parseQuasiQuoted :: Parser LispVal
parseQuasiQuoted = do
    char '`'
    x <- parseExpr
    return $ List [Atom "quasiquote", x]

parseUnQuote :: Parser LispVal
parseUnQuote = do
    char ','
    x <- parseExpr
    return $ List [Atom "unquote", x]
```

Expression parser:
```haskell
-- |Parse an Expression
parseExpr :: Parser LispVal
parseExpr = try parseComplex
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
```

The symbols `'expr`, `` `expr``, and `,expr` are shorthands and are
correspondingly transformed by the parser into the
AST equivalent of the expressions:
`(quote expr)`, `(quasiquote expr)` and `(unquote expr)`.
In fact, the shorthand and list syntaxes are interchangeable. `unquote` makes sense only inside a `quasiquote`d block

After defining the parsing rules for quoting and unquoting, it is time to define
the corresponding evaluation rules as `eval` pattern matching cases:

```haskell
-- Evalaute a quoted expression, just return the value.
eval env (List [Atom "quote", val]) = return val
-- ...

-- Evaluate quasiquotation. AKA macro expander.
-- Recursively evaluate unquote forms, or just return the items if not unquoted
eval env (List [Atom "quasiquote", form]) =
    evalUnquotes form
    where evalUnquotes form =
            case form of
                List [Atom "unquote", form] -> eval env form
                List items -> do
                    results <- traverse evalUnquotes items
                    return $ List results
                _ -> return form
```

Here's an example, showing what happens when entering quoted expressions
in **yasih**'s REPL.
```scheme
λ> ; here, the evaluator tries to apply
λ> (1 2 3) ; 2 and 3 as arguments to a function "1"
Not a function: : "1"
λ> ; the result is clearly not a function
λ> ; the list here is now quoted and will be treated as a literal value
λ> '(1 2 3)
(1 2 3)
λ> `(1 2 3) ; same here but using quasiquote
(1 2 3)
λ> `(1 2 ,(+ 4 5)) ; the unquoted expression is evaluated! (un-quoted)!
(1 2 9)
```

After we have working quotation and quasiquotation it is time to add actual macros to the interpreter.
I had to change the expression data type by adding an `isMacro` field.
```haskell
-- |Lisp Value data type
data LispVal =
    -- Other data types here...
    | Func {
        isMacro :: Bool,
        params :: [String], -- Parameters name
        vararg :: Maybe String, -- name of a variable-length argument list
        body :: [LispVal], -- list of expressions
        closure :: Env -- the environment where the function was created
        }
    | IOFunc ([LispVal] -> IOThrowsError LispVal) -- A dirty function that performs IO
    | Port Handle -- Represents input and output devices
```

The important bit was changing `eval`'s function application clause by
checking if a called function is a macro, and if so changing
from eager evaluation order of the arguments to a normal-order evaluation.
Read more about evaluation models [here](https://cs.stackexchange.com/questions/54000/is-applicative-order-and-normal-order-evaluation-models-definition-contradictor) (huge thanks to Rei for the link).

```haskell
-- Function application clause
-- Run eval recursively over args then apply func over the resulting list
eval env (List (function : args)) = do
    func <- eval env function
    case func of
        Func {isMacro = True} -> apply func args >>= eval env
        _ -> mapM (eval env) args >>= apply func
```

You can see that if the applied function is a macro, then `eval env` is not called over the arguments.
Minor changes were needed also in `apply`, just adding an `isMacro` deconstructor to the case where `Func`
is passed as an argument. It is not needed by now inside `apply`'s body.
```haskell
apply (Func isMacro params varargs body closure) args =
    -- more code...
```

Now, it's time to add some helper functions in `Environment.hs` to make a macro
```haskell
-- |Helper functions to create function objects in IOThrowsError monad
makeFunc :: Bool -> Maybe String -> Env -> [LispVal] -> [LispVal] -> IOThrowsError LispVal
makeFunc isMacro varargs env params body = return $ Func isMacro (map showVal params) varargs body env
makeNormalFunc = makeFunc False Nothing
makeVarargs = makeFunc False . Just . showVal
makeMacro = makeFunc True Nothing
```

Finally, a `define-syntax` form can be defined to make macros.
I have not yet implemented `syntax-rules` but i surely will in the next **yasih** updates.
```haskell
-- Define a macro
eval env (List (Atom "define-syntax" : List (Atom var : params) : body)) =
    makeMacro env params body >>= defineVar env var
```

Here's an example on how you can make a macro and use it as a practical construct
for a programming language.
Here, the `let` statement is defined as a macro that will expand to an anonymous function
(lambda) application, in this way a closure will be made and lexical scoping will be respected,
correctly reaching the `let` statement's goals. The implementation is a little sketchy and
will surely get better as `syntax-rules` gets implemented.

```scheme
(define-syntax (bind-vars bindings)
    `(map car bindings))

(define-syntax (bind-vals bindings)
    `(map cadr bindings))

(define-syntax (let bindings body)
    `(apply (lambda ,(bind-vars bindings) ,body) ',(bind-vals bindings)))
```

```scheme
(let ((x 1) (y 4)) (- (* y y) (+ 1 x)))
; will expand to
((lambda (x y) (- (* y y) (+ 1 x))) 1 4)
; before being executed
```


This practice is called `let-over-lambda`.
Some modern functional programming languages like OCaml, directly create a closure instead of
creating an anonymous function for `let` statements;
that practice is fairly more performant, but the execution result is identical.

## Some updates on yasih's development.

A sketchy complete R5RS implementation is almost done.
Some primitives are still missing and I will work on them in the next updates, in which I will also
focus on adding additional features like string interpolation, stack tracing, and probably
optimization features like a garbage collector.
