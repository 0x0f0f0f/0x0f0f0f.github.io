@def title = "minicaml, a didactical OCaml-like functional programming language."
@def rss =  "minicaml, a didactical OCaml-like functional programming language."
@def published = "04 December 2019"
@def tags = ["functional-programming", "ocaml", "minicaml"]

{{post_header}}

**[minicaml](https://github.com/0x0f0f0f/minicaml)** is a small, purely functional interpreted programming language with
a didactical purpose. I wrote **[minicaml](https://github.com/0x0f0f0f/minicaml)** for the **Programming 2** course at
the University of Pisa, taught by Professors Gianluigi Ferrari and Francesca
Levi. It is based on the teachers'
[minicaml](http://pages.di.unipi.it/levi/codice-18/evalFunEnvFull.ml), an
evaluation example to show how interpreters work. It is an interpreted subset of
Caml, with eager evaluation and only local (`let-in`) declaration statements. I
have added a simple parser and lexer made with menhir and ocamllex ([learn
more](https://v1.realworldocaml.org/v1/en/html/parsing-with-ocamllex-and-menhir.html)).
I have also added a simple REPL that shows each reduction step that is done in
evaluating an expression. I'd also like to implement a simple compiler and abstract
machine for this project.

**[minicaml](https://github.com/0x0f0f0f/minicaml)** only implements basic data types (integers and booleans) and will
never be a full programming language intended for real world usage. **[minicaml](https://github.com/0x0f0f0f/minicaml)'s only
purpose is to help students get a grasp of how interpreters and programming
languages work**.

![minicaml](/assets/images/minicaml.png)

## Features

* Show the AST of each expression
* Only boolean and integer types
* Pretty color REPL showing every step made in evaluating a program
* Only local declaration statements
* Recursive functions and closures
* ocamllex and menhir lexer and parser
* Extensible with ease

## Installation
I will release a binary file (no need to compile) in the near future. To
install, you need to have `opam` (OCaml's package manager) and a recent OCaml
distribution installed on your system.
[rlwrap](https://github.com/hanslub42/rlwrap) is suggested for a readline-like
(bash-like) keyboard interface.

```bash
# clone the repository
git clone https://github.com/0x0f0f0f/minicaml
# cd into it
cd minicaml
# install dependencies
opam install dune menhir ANSITerminal
# compile
make
# run
make run
# rlwrap is suggested
rlwrap make run
# you can install minicaml with
make install
# run again
rlwrap minicaml
```

## Usage

Run `make run` to run a REPL. The REPL shows the AST equivalentof each submitted
expression, and each reduction step in the evaluation is shown. It also signals
syntactical and semantical errors.

Please let me know if you find bugs or have any improvement in mind!