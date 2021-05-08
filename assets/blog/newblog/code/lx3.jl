# This file was generated, do not modify it. # hide
using Latexify 
ls = @latexrun f(x; y=2) = x/y
println(ls.s) # hide