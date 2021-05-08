# This file was generated, do not modify it. # hide
using Latexify
ex = :(x/(y+x)^2)
ls = latexify(ex; env=:eq)
println(ls.s) # hide