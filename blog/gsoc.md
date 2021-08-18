@def title = "Metatheory.jl and Julia Symbolics - GSOC 2021"
@def rss =  "Metatheory.jl and Julia Symbolics - GSOC 2021"
@def published = "18 August 2021"
@def tags = ["julia", "metatheory.jl", "metatheory", "symbolics", "gsoc"]

{{post_header}}

## Google Summer of Code 2021

This year I've applied for Google Summer of Code. My proposed project involved
many practical applications of [e-graph term rewriting](https://dl.acm.org/doi/pdf/10.1145/3434304)
for existing packages in the Julia programming language ecosystem through my package
[Metatheory.jl](https://github.com/0x0f0f0f/Metatheory.jl).

See the GSoC project page [here](https://summerofcode.withgoogle.com/projects/#4792510246813696).

Metatheory.jl is a general purpose metaprogramming and algebraic computation
library for the Julia programming language, designed to take advantage of the
powerful reflection capabilities to bridge the gap between symbolic mathematics,
abstract interpretation, equational reasoning, optimization, composable compiler
transforms, and advanced homoiconic pattern matching features. The core feature
of Metatheory.jl is e-graph rewriting, a fresh approach to term rewriting
achieved through an equality saturation algorithm. Our implementation of
equality saturation on e-graphs is based on the excellent, state-of-the-art
technique implemented in the [egg library](egraphs-good.github.io/),
reimplemented in pure Julia. MT (Metatheory.jl for short) allows users to define
concise rewriting rules in pure, syntactically valid Julia on a high level of
abstraction.

There is a lot of unexplored potential behind this novel technique of
e-graph rewriting, and Julia felt like the natural language where we
could explore and unleash this great symbolic manipulation potential.


## Talk at JuliaCon

During this period of time, me and [Philip Zucker](https://www.philipzucker.com/) have prepared a talk for the [JuliaCon 2021](https://juliacon.org/2021/) conference explaining Metatheory.jl and its potential. I have to thank Philip for being the first person to have the idea to implement e-graph rewriting in Julia. You can check out his early blog posts showcasing the ideas [here](https://www.philipzucker.com/egraph-1/) and [here](https://www.philipzucker.com/egraph-2/).
Before reading this article, which goes quite into technical implementation details, I strongly suggest readers to 
take a look at the [Recommended Readings](https://github.com/0x0f0f0f/Metatheory.jl#recommended-readings---selected-publications) section in the Metatheory.jl README file. In this 25 min talk, 
we try to give an high level explanation of most things and facts behind the equality saturation algorithm, e-graph rewriting and why Metatheory.jl can be useful in the Julia ecosystem.

~~~
<iframe width="560" height="315" src="https://www.youtube.com/embed/tdXfsTliRJk" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
~~~

Another great talk which explains the equality saturation algorithm more concisely has been given by Max Willsey for [POPL21](https://popl21.sigplan.org/). Please note that this lightning talk is about the original [egg](https://egraphs-good.github.io/) library, implemented in Rust. Watch the talk [here](https://www.youtube.com/watch?v=m001XqQKyCQ&t=61s).

We will also discuss some SymbolicUtils.jl and Symbolics.jl implementation details. You can check out this 
talk by Shashi Gowda and Yingbo Ma about Symbolics.jl at JuliaCon 2021: 

~~~
<iframe width="560" height="315" src="https://www.youtube.com/embed/Vkz4c-lDMU8" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
~~~

## Goals Proposed

For this GSOC project, I've proposed a bunch of goals, though, all these goals
imply a large amount of work that is impractical to tackle alone. Completing all
of them would have required a huge amount of time. Together with my mentor Sashi
Gowda, we pinpointed and chosen some of these goals that fit most in the GSoC
period, most regarding the SymbolicUtils.jl and Symbolics.jl integration with Metatheory.jl

- Make MT produce proof certificates, possibly with the algorithm
  described in [Proof Producing Congruence Clousre](https://www.cs.upc.edu/~oliveras/espai/papers/rta05.pdf).
- Improve rewriting performance by introducing goal informed rule
  schedulers. Rule schedulers are an heuristic that prunes the search
  space of rewrite rules. With a more informed heuristic, MT will make
  smarter decisions when rewriting, to reach desired goals faster. This
  topic is very hot in research and will significantly improve
  performance of all the other possible project goals.
- Show some working implementations of compiler optimizations on Julia's
  IRs and compare them to the existing built-in optimizer, possibly with
  the [Mixtape.jl](https://github.com/JuliaCompilerPlugins/Mixtape.jl) infrastructure.
- Produce a system that allows for automated category theory reasoning,
  proof production and assistance.
- Integrate MT with [Symbolics.jl](https://github.com/JuliaSymbolics/Symbolics.jl) and [SymbolicUtils.jl](https://github.com/JuliaSymbolics/SymbolicUtils.jl/)
- Integrate MT with [Catlab.jl](https://github.com/AlgebraicJulia/Catlab.jl/)
- Re-implement rewrite systems from [Symbolics.jl](https://github.com/JuliaSymbolics/Symbolics.jl),
  benchmark and show if there are
  improvements and if so, under which conditions MT is more performant.
- Reproduce in pure Julia (and possibly improve) equality saturation
  optimization tasks from at least one of these papers:
  [herbie](https://herbie.uwplse.org/), [TENSAT](https://arxiv.org/abs/2101.01332), [SPORES](https://arxiv.org/abs/2002.07951).
- Borrow ideas from the other points in categorical string diagrammatic
  reasoning to see where they could be applied to provide improvements
  to existing optimizers like SPORES or herbie.
- Produce valid research papers about the showcased topics, highlighting
  contributions to the Julia language and community efforts.

## Positive and Negative Results

Not all of the goals have been achieved. We achieved many positive results in integrating
MT with [SymbolicUtils.jl](https://github.com/JuliaSymbolics/SymbolicUtils.jl/) and [Symbolics.jl](https://github.com/JuliaSymbolics/Symbolics.jl), while we've encountered some problems that caused a slowdown in researching e-graph rewriting
for category theoretical applications.
Here's a recap of the positive results achieved:

## What's new in Metatheory.jl

The latest release of Metatheory.jl is [0.4.1](https://github.com/0x0f0f0f/Metatheory.jl/releases/tag/v0.4.1). Here are the 
things that changed in the package approximately since the start of GSoC:

- The pattern matcher has been completely renewed and is now based on a virtual machine, based on 
  [Efficient E-matching for SMT Solvers](http://leodemoura.github.io/files/ematching.pdf) by [Leonardo de Moura](https://leodemoura.github.io/), author of the Lean and Z3 theorem provers.
- MT is now dozens of times faster than before.
- Equality saturation now shows detailed execution reports: 
```
┌ Info: Equality Saturation Report
│ =================
│       Stop Reason: Iteration Timeout
│       Iterations: 8
│       EGraph Size: 2 eclasses, 1165 nodes
│       Total Time: (time = 0.084321744, bytes = 25927056, gctime = 0.012734903)
│       Search Time: (time = 0.051270235000000004, bytes = 18560096, gctime = 0.012734903)
│       Apply Time: (time = 0.025271813000000004, bytes = 5952600, gctime = 0.0)
└       Rebuild Time: (time = 0.007779695999999999, bytes = 1414360, gctime = 0.0)
```
- It is now easier to pass parameters to the algorithm, with a new `SaturationParams` type:
```julia
"""
Configurable Parameters for the equality saturation process.
"""
@with_kw mutable struct SaturationParams
    timeout::Int = 8
    matchlimit::Int = 5000
    eclasslimit::Int = 5000
    enodelimit::Int = 15000
    goal::Union{Nothing, SaturationGoal} = nothing
    stopwhen::Function = ()->false
    scheduler::Type{<:AbstractScheduler} = BackoffScheduler
    schedulerparams::Tuple=()
end
```
- Rule schedulers have been improved a lot. Rule schedulers are interchangeable tactics that help trim 
  and reduce the search space in terms of applicable rules when running equality saturation on an e-graph.
  Reducing the number of applicable rules helps speeding up the process of searching for a goal expression in many equivalent
  expressions represented by an e-graph.
- Completely changed the metadata system, it is now much faster and more idiomatic. 
- Added a new interface for rewriting on custom types (more on this later!).
- Patterns and rules can now be built programmatically and idiomatically with a custom interface.
- Literal objects can be interpolated in the `@theory` macro using the unary `$` operator, similarly to what happens in quoting/unquoting when using the native Julia metaprogramming primitives. 
- Many issues have been fixed and closed
- Added many examples regarding category theory and symbolic mathematics in the [test folder](https://github.com/0x0f0f0f/Metatheory.jl/tree/master/test).


## What about TermInterface.jl?

We have decided, together with Shashi, to create [TermInterface.jl](https://github.com/JuliaSymbolics/TermInterface.jl), a package that defines a shared interface for all the common operations on symbolic terms and expressions, a feature
that is missing in the `Base` module in the Julia standard library and is only present for the native `Expr` type.
I have then updated Metatheory.jl, Symbolics.jl and SymbolicUtils.jl to support this shared interface and it is working great.

The evil plan consists of a simple design choice: any type that overrides and dispatches on the `TermInterface.jl` functions can be used as a symbolic expression in all the Julia packages that do symbolic manipulation and term rewriting magic: Symbolics.jl, SymbolicUtils.jl and Metatheory.jl (and possibly more!).

## Unreleased Changes in Metatheory.jl!

However, I am close to release version `0.5` of Metatheory.jl with the full integration with TermInterface.jl (and consequently SymbolicUtils.jl and Symbolics.jl)!
Here are the [new commits](https://github.com/0x0f0f0f/Metatheory.jl/compare/v0.4.1...master) on the `master` branch 
since the `0.4.1` release. What is new and close to be released?

- Removed dependency on the unmaintained MatchCore.jl package, now MT has an internal pattern matcher based on `TermInterface.jl`.
- Removed bad and ugly global compilation caches for rules, now both dynamic and symbolic rules are eagerly compiled, garbage collected and uber fast.
- Completely redesigned the classical rewriting part, so that now one can define rewriting strategies using `SymbolicUtils.Rewriters` combinators!
- Rules can now be called as functions. Other than being elegant, this was crucial for the MT-SU integration: now *MT rules can be used as SymbolicUtils rules*!
- There is now an abstract type for rules so that one can define other new rule types.

Before releasing this new version tho, my PR has to be merged in SymbolicUtils.jl, since I want to add a dependency on it for `Rewriters` combinators.


## SymbolicUtils.jl + Metatheory.jl = 🚀

The integration with `TermInterface.jl` is still on PR branches of SymbolicUtils.jl and Symbolics.jl, so you have to manually add my branches if you want to try. ([SU PR](https://github.com/JuliaSymbolics/SymbolicUtils.jl/pull/302) and [Symbolics PR](https://github.com/JuliaSymbolics/Symbolics.jl/pull/286)), please note that it is still a **work in progress**.

First, a `Symbolics.optimize` function has been introduced. It takes a symbolic expression and returns another (numerically-approximately) equivalent expression which is less costly to compute, the cost function for optimization is defined to approximate the cost in CPU cycles. 

This is based on the work that we published in the paper ['High-performance symbolic-numerics via multiple dispatch'](https://arxiv.org/abs/2105.03949), submitted to arxiv in May with Shashi Gowda, Yingbo Ma, Maja Gwozdz, Viral B. Shah, Alan Edelman and Christopher Rackauckas. We showcase an e-graph ruleset which optimizes Symbolics.jl expressions minimizing the number of CPU cycles during expression evaluation, and demonstrate how it simplifies a real-world chemical reaction-network from a [Catalyst.jl](https://github.com/SciML/Catalyst.jl) simulation to halve the runtime required, all thanks to this new TermInterface.jl integration between Symbolics.jl and Metatheory.jl 

We submitted the paper to the [ISSAC 2021](https://issac-conference.org/2021/) conference, Chris Rackauckas has given a nice talk about the paper, Symbolics.jl and also explaining the Metatheory.jl integration in detail.

~~~
<iframe width="560" height="315" src="https://www.youtube.com/embed/rFzWuXu7wFA" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
~~~

Metatheory.jl rules now are callable functions (as SU rules), so one can do cool things using SU's Rewriter combinators (and more). Metatheory.jl classical rewriting module was slow and unstable so now most of the magic happens thanks to what was already in SU, Here is a short demo of how it will work.

```julia
using Metatheory.jl
using SymbolicUtils
using SymbolicUtils.Rewriters

arithm_rules = @theory begin
	(a + b, σ) 		  => (a, σ) + (b, σ)
	(a * b, σ) 		  => (a, σ) * (b, σ)
	(a - b, σ) 		  => (a, σ) - (b, σ)
	(a::Int + b::Int) |> a + b
	(a::Int * b::Int) |> a * b
	(a::Int - b::Int) |> a - b
	(n::Int, σ) |> n
end

strategy = (Fixpoint ∘ Postwalk ∘ Fixpoint ∘ Chain)

eval_arithm(ex, mem) = 
	strategy(read_mem ∪ arithm_rules)(:($ex, $mem))
```

All the `operation, similarterm, arguments` and `istree` methods in my branches of Symbolics and SU have been moved and renamed to dispatches of the functions in the TermInterface.jl package, namely `gethead, similarterm, getargs, isterm`.
There's still some things to polish. Some codegen and minor things are broken, the core works fine and I have to define deprecated methods to make it still work with other packages such as [ModelingToolkit.jl](https://mtk.sciml.ai/stable/). Most importantly it allows developers to implement a simple interface for their symbolic expression types to be handled by both Metatheory (EGraph rewriting) and Symbolics and potentially by any other symbolic magic package.
This provides `Expr` dispatches as symbolic types by default. 

A working demo/blogpost of Metatheory.jl optimizing a Catalyst.jl chemical reaction network through Symbolics.jl is coming soon! 

## Ideas for Future Work on SymbolicUtils.jl

After working with SymbolicUtils and Symbolics, I have a couple of suggestions/critics for some SymbolicUtils.jl design choices. I'm eager to dedicate some time to code and improve the packages in the near future.

- There is no distinction between symbolic rules and dynamic rules (pattern matched guarded lambdas) in SymbolicUtils.jl. Everything is a dynamic rule. This implies that one has to pirate (or define) all the methods that appear as function calls in the symbolic code that is being manipulated: See [here](https://github.com/JuliaSymbolics/SymbolicUtils.jl/blob/master/test/interface.jl). Note that TermInterface.jl will supersede those interface methods in my branch of SymbolicUtils.jl. 
  This is quite impractical for code generation and optimization tasks.
  Here's the bad type piracy code in that test file.
```julia
for f ∈ [:+, :-, :*, :/, :^]
    @eval begin
        Base.$f(x::Union{Expr, Symbol}, y::Number) = Expr(:call, $f, x, y)
        Base.$f(x::Number, y::Union{Expr, Symbol}) = Expr(:call, $f, x, y)
        Base.$f(x::Union{Expr, Symbol}, y::Union{Expr, Symbol}) = (Expr(:call, $f, x, y))
    end
end
```
- Separate some parts of SymbolicUtils.jl into different packages, first, it would be great to separate the Rewriters module into a different package, so that both Metatheory.jl and SymbolicUtils.jl can depend on it. Same suggestion goes for the part of the code handling the definition and application of rules, so that rules can be used interchangeably.
- Another idea for future work is to experiment using Metatheory.jl to improve and simplify the Symbolics.jl codegen (at least for native reflective Julia code). It would be cool do redesign some parts of the Symbolics.jl => Julia  compiler pipeline with rewriting steps using both EGraphs and classical rewriting on both `<:Symbolic` and `Expr` types. This will require quite some time.

## YaoEGraph.jl

What about the goals about IR rewriting in the compiler pipeline? Sadly, the time was short and focusing on all the symbolic mathematics, Metatheory.jl internals and compiler pipeline goals at the same would have been too hard for me in a single summer.
Together with Chen Zhao and Roger Luo, we discussed and proposed some experiments of Metatheory.jl e-graph rewriting for optimizing their *quantum circuit IR* for their quantum computing package [Yao.jl](https://github.com/QuantumBFS/Yao.jl/)!

This work is still in an early stage, but you can check out our experiments in this repo [YaoEGraphs.jl](https://github.com/ChenZhao44/YaoEGraph.jl). If this high level optimization use case is successful, this will show that optimizing with e-graph rewriting is also practicable on the various native Julia compiler IRs. McCoy Becker has also spent a lot of time working in his [Compiler Plugin Github Organization](https://github.com/JuliaCompilerPlugins/), we tried to experiment a bit in optimizing Julia code using his package [Mixtape.jl](https://github.com/JuliaCompilerPlugins/Mixtape.jl) and Metatheory.jl, but in the end, during the past few months we didn't really end up defining a TermInterface.jl implementation for the native Julia IR constructs (or higher level abstractions).

## Results with Category Theory and Catlab.

Regarding the (currently negative) results about rewriting in category theory,
we have experimented a lot with Philip Zucker and James Fairbanks. The
[Catlab.jl](https://github.com/AlgebraicJulia/Catlab.jl/) package, designed for
modeling category theoretical and algebraic constructs inside of Julia works
through a different kind of symbolic expression, based on the theory of
Generalized Algebraic Theories. These expressions require a complex way of
embedding their types into the expressions. In higher order category contexts, those type tags often directly contain
other expressions and not only 'type objects'. We tried many different encodings of those 'type tags' and
tried to produce some proofs in various categories, but we found out that the
equality saturation algorithm sometimes does not terminate even on trivial proofs and 'loses' a lot of time trying 
to apply equalities that are not relevant for the proof in question.

This is why we need:
- Better trimming of the rule space through rule
  schedulers, some sort of algorithm providing "guidance" to equality saturation
  through the proofs/rewrites. We have currently proposed many ideas for this solving this problem.
- An algorithm that provides human readable proofs that are verifiable in polynomial time, to debug and understand where does equality saturation get lost in the jungle of rewrites.  

## Proof Certificates are Hard

Seeing why an e-graph rewrite fails is **hard**. This is why, when experimenting
with rewriting for Catlab.jl expressions I have spent quite some time trying to
design and implement an algorithm that provides an human readable proof (trace
of rule application), after Metatheory.jl tries to prove that two expressions
are equal using e-graphs. Max Willsey then let me know that Oliver Flatt is
working on this problem on the Rust side of this e-graph rewriting world. In a
long video chat with Oliver, he explained to me his new, almost finished
algorithm. Turns out this task is much more complicated than I've expected, so,
I've decided to focus on the Symbolics.jl integration goal for the rest of the
GSoC, leaving this much harder problem for future work together with Catlab.jl
integration.

## Acknowledgments

I have to thank Max Willsey for creating the awesome egg library, Philip Zucker for having the awesome idea of implementing e-graph rewriting in Julia, Shashi Gowda and Keno Fisher for mentoring me in this GSoC project.
Shashi Gowda, Yingbo Ma, Maja Gwozdz, Viral B. Shah, Alan Edelman, Christopher Rackauckas for giving me the awesome opportunity to co-author the Symbolics.jl paper with them, Shashi Gowda, Chris Rackauckas and Yingbo Ma for helping me understand more and work on Symbolics.jl and SymbolicUtils.jl and introducing me in the JuliaSymbolics Github organization. Filippo Bonchi for teaching me a lot about category theory and guiding me through this work, with many friendly revisions of my talks and papers. Evan Patterson and James Fairbanks for creating Catlab.jl, helping me understand it and work with it, Chen Zhao and Roger Luo for their interest in my project and letting me experiment with them on the Yao quantum IR, McCoy Becker for explaining me a lot about how the Julia compiler internals work, and for his Mixtape.jl package and his experiments with Metatheory.jl, Marek Kaluba for his interest in the project and for showing me some cool group theoretical problems, Miguel Raz Guzmán Macedo for his support, Taine Zhao for the MatchCore.jl library and help during the initial development phase of Metatheory.jl. Thanks to Philip Zucker, Chen Zhao, David P. Sanders, Greg Peairs, Mosè Giordano, 'NumHack' and McCoy R. Becker for contributing to the Metatheory.jl package on Github, and finally, thanks to everybody that has given me support in my project from the beginning!