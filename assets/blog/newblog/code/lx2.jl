# This file was generated, do not modify it. # hide
using Latexify
arr = rand(ComplexF16, (2,2))
ls = latexify(arr) # this is an L string
println(ls.s) # hide