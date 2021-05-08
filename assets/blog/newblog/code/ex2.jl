# This file was generated, do not modify it. # hide
using PlotlyJS, Latexify
ls = @latexrun f(x, y) = sin(x) + cos(y)
n = 24
z = [ [f(x,y) for y in 1:n] for x in 1:n]
println("Here is the plot for ", ls.s) # hide
function topo_surface()
    trace = surface(z=z, colorscale="Viridis")
    layout = Layout(title="", autosize=false, width=600, height=500)
    plot(trace, layout)
end
plt = topo_surface()
fdplotly(json(plt); style="width:600px;height:500px")