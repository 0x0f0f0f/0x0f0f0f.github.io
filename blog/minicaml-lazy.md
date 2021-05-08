@def title = "Implementing optional lazy evaluation for minicaml"
@def published = "12 December 2019"
@def tags = ["functional-programming", "ocaml", "minicaml"]

{{post_header}}

As an experiment, I've decided to add lazy evaluation to the didactical
programming language [minicaml](https://github.com/0x0f0f0f/minicaml). It have
not yet implemented a cache for values that have already been evaluated. Here is how I
did it.


The first thing I had to do was creating an additional wrapper type that
tells the evaluator if a value has already been evaluated or not, change
the environment type so that it can contain both kind of values and change the
"evaluation result" type so that it contains constructors for lazy functions and
recursive lazy functions (see more later in the function application `eval` case).
Notice, in `type_wrapper`, how already evaluated values are of kind `evt`
("evaluated" or "reduced" expression), while `LazyExpression` values are just
AST expressions that have not been evaluated yet.

```ocaml
(* lib/types.ml *)

(** A type that represents an evaluated (reduced) value *)
type evt =
    | EvtUnit
    | EvtInt of int
    | EvtBool of bool
    | EvtList of evt list
    | Closure of ide list * expr * (type_wrapper env_t)
    | LazyClosure of ide list * expr * (type_wrapper env_t)
    | RecClosure of ide * ide list * expr * (type_wrapper env_t)
    | RecLazyClosure of ide * ide list * expr * (type_wrapper env_t)
    [@@deriving show { with_path = false }]
and type_wrapper =
    | LazyExpression of expr
    | AlreadyEvaluated of evt
    [@@deriving show]

(** An environment of already evaluated values  *)
type env_type = type_wrapper env_t
```

The next step was adding AST types for `let lazy` and `lazyfun` statements and
the corresponding parser and lexer definitions.
`let lazy x = (... some expression ...) in (... body expression ...)` binds a `LazyExpression`
to the symbol x in the `body` expression's environment. The evaluator only
evaluates the expression bound to `x` when the symbol is encountered and used in
the `let lazy` statement's body; while a normal `let` statement evaluates the
expression assigned to `x` before evaluating the body (a practice called eager
evaluation).

#### These camels are quite lazy:
![These camels are lazy](/assets/images/lazy-camels.jpg)

The same thing applies to functions and their actual parameters. In eager
evaluation (the default in minicaml), when you apply a function to some
arguments, the arguments are evaluated before actually evaluating the function
body (and therefore are bound to a `AlreadyEvaluated` constructor in the
environment), while in `lazyfun` (lazily evaluated functions) the arguments are
not evaluated until encountered in the body (and therefore they are bound to a
`LazyExpression` constructor).

```ocaml
(* lib/types.ml *)

(** A value identifier*)
type ide = string
[@@deriving show]

(** The type representing Abstract Syntax Tree expressions *)
type expr =
    (* ... other constructors are not shown here for simplicity  ... *)
    | Let of ide * expr * expr
    | Letlazy of ide * expr * expr
    | Letrec of ide * expr * expr
    | Lambda of ide list * expr
    | LazyLambda of ide list * expr
    | Apply of expr * expr list
    [@@deriving show { with_path = false }]
```

Next, I had to change the `lookup` function, which searches for bindings in the
environment. If, for a certain symbol `x` the `lookup` function encounters an
`AlreadyEvaluated` value in the environment, it just returns it. If it
encounters a `LazyExpression` value it means that it has encountered a value
that was previously defined in a `let lazy` statement or a `lazyfun` function
application, and it has to evaluate it and return the result. This is not
exactly efficient, since if you encounter a lazily-defined expression twice, it
is evaluated at the time of the first encounter, and at the second encounter you
have no way of telling that its value was already calculated if you use an
immutable, purely functional environment; therefore you have to evaluate it
twice, or introduce an evaluation cache. The final step is changing the
evaluation function, so that it correctly interprets `LazyLambda`, `Letlazy`
expressions and `LazyClosure` and `RecLazyClosure` application. Note that `eval`
and `lookup` have now become mutually recursive and they have to be defined
together with `and`.

```ocaml
(* lib/eval.ml *)

let rec eval (e: expr) (env: env_type) (n: stackframe) : evt =
    let n = push_stack n e in
    let evaluated = (match e with
    (* ... The rest of evaluation cases are omitted for simplicity ... *)
    | Symbol x -> lookup env x n
    | Let (ident, value, body) ->
        eval body (bind env ident (AlreadyEvaluated (eval value env n))) n
    | Letlazy (ident, value, body) ->
        eval body (bind env ident (LazyExpression value)) n
    | Letrec (ident, value, body) ->
        (match value with
            | Lambda (params, fbody) ->
                let rec_env = (bind env ident
                    (AlreadyEvaluated (RecClosure(ident, params, fbody, env))))
                in eval body rec_env n
            | LazyLambda (params, fbody) ->
                let rec_env = (bind env ident
                    (AlreadyEvaluated (RecLazyClosure(ident, params, fbody, env))))
                in eval body rec_env n
            | _ -> raise (TypeError "Cannot define recursion on non-functional values"))
    | Lambda (params,body) -> Closure(params, body, env)
    | LazyLambda (params,body) -> LazyClosure(params, body, env)
    | Apply(f, params) ->
        let closure = eval f env n  in
        (match closure with
        | Closure(args, body, decenv) -> (* Use static scoping *)
            let evaluated_params = List.map (fun x -> eval x env n ) params in
            let application_env = bindlist decenv args (List.map (fun x ->
                 AlreadyEvaluated x) evaluated_params)  in
            eval body application_env n
        | RecClosure(name, args, body, decenv) ->
            let evaluated_params = List.map (fun x -> eval x env n ) params in
            let rec_env = (bind decenv name (AlreadyEvaluated closure)) in
            let application_env = bindlist rec_env args
                (List.map (fun x -> AlreadyEvaluated x) evaluated_params) in
            eval body application_env n
        | LazyClosure(args, body, decenv) ->
            let application_env = bindlist decenv args
                (List.map (fun x -> LazyExpression x) params) in
            eval body application_env n
        | RecLazyClosure(name, args, body, decenv) ->
            let rec_env = (bind decenv name (AlreadyEvaluated closure)) in
            let application_env = bindlist rec_env args
                (List.map (fun x -> LazyExpression x) params) in
            eval body application_env n
        | _ -> raise (TypeError "Cannot apply a non functional value")))
    in let depth = (match n with
        | StackValue(d, _, _) -> d
        | EmptyStack -> 0)
    in
    print_message ~color:T.Blue ~loc:(Nowhere)
        "Reduction at depth" "%d\nExpression:\t%s\nEvaluates to:\t%s\n" depth (show_expr e) (show_evt evaluated);
    evaluated;
(* Search for a key in an environment (a (string, value) pair) *)
and lookup (env: env_type) (ident: ide) (n: stackframe) : evt =
    if ident = "" then failwith "invalid identifier" else
    match env with
    | [] -> raise (UnboundVariable ident)
    | (i, LazyExpression e) :: env_rest -> if ident = i then eval e env n
        else lookup env_rest ident n
    | (i, AlreadyEvaluated e) :: env_rest -> if ident = i then e else
        lookup env_rest ident n
```

You can find minicaml version `0.2.1` with laziness
[here](https://github.com/0x0f0f0f/minicaml/releases).
Thanks to Antonio for helping me reason about implementing laziness.