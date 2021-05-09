@def title =  "New Blog with Franklin.jl"
@def rss =   "New Blog with Franklin.jl"
@def published = "08 May 2021"
@def tags = ["blog", "julia"]

{{post_header}}

I've just finished migrating by blog from the [hugo](https://gohugo.io)
static site generator to [Franklin.jl](https://franklinjl.org/)!

While the website layout seems a lot more austere than how it looked
before, using Franklin.jl comes with a lot of advantages.
I migrated to a new SSG because I wanted to introduce some new features
First of all, themes and layoutting are much simpler with Franklin, less HTML layout files to code around.

## HTML Functions

Another good reason for using Franklin.jl, is that creating HTML functions (shortcodes for templating HTML) 
feels much simpler with Julia. No Go code to compile and bundle with hugo. Just define html functions as regular Julia functions
in `utils.jl` in your website source root, and let Julia magic do the rest. Julia also feel like the natural language to do this sort of stuff 
and is filled with goodies in the standard library that make templating a website a fun and easy task.
A typical HTML function in Franklin.jl looks like this:

```julia
"""
    {{navbar_items_list}}

Generate an appropriate list of navbar items
"""
function hfun_navbar_items_list()::String
    io = IOBuffer()
    nav_items = collect(globvar("navbar_items"))
    for i in 1:length(nav_items)
        (title, url) = nav_items[i] 
        write(io, "<a href=\"$url\">$title</a>")
        if i < length(nav_items)
            write(io, " / ")
        end
    end

    return String(take!(io))
end
```

With Franklin's markdown syntax, you can define Julia variables inside your markdown documents by using 
```
@def varname = value
```  

You can keep the global config for your website in a Markdown file, and can define variables and metadata
locally for single pages by just including `@def`initions in your `.md` files.
The function above, reads the list of navbar items from the global `config.md` file with `globvar("navbar_items")`.
The navbar items are defined as a regular Julia array of pairs
```julia
navbar_items = ["Home" => "/", "Blog" => "/blog", "Tags" => "/tag/"]
```
After reading the config variable, the function above can then write some html to an `IOBuffer` 
and generate the HTML code for the navbar links in the website.
To call the HTML function, in the file `_layout/navbar.html` we put the shortcode `{{navbar_items_list}}` like this 


```html
<nav>
    {{navbar_items_list}}
    <div class="social-media">
        <a style="color: #000000;" href="{{git_url}}"><i class="fab fa-github"></i></a>
        <a style="color: #000000;" href="{{twitter_url}}"><i class="fab fa-twitter"></i></a>
    </div>
</nav>
```
(I still have to do the same for social network icons)

See the [Franklin.jl Page Variables](https://franklinjl.org/syntax/page-variables/) doc section for more details 
on how to play around with Julia and HTML in Franklin.

## Math rendering with KaTeX

[KaTeX](https://katex.org/) is a Javascript library for typesetting LaTeX code in web pages.
With *hugo*, support for Mathjax and KaTeX depended pretty much on the theme used. With 
Franklin, KaTeX support is basically built in, and with a couple of additions it is easy to 
*pre-render* SVGs to have js-free maths in the browser!

Here's an example


\begin{eqnarray}
    \begin{aligned}
      o = \begin{pmatrix}
        2 & 1 & 1
      \end{pmatrix} & \quad &  
      T_a = \begin{pmatrix}
        1 & \frac{1}{3} & 1 \\ 
        0 & 0 & 0 \\
        0 & 0 & 0 \\ 
      \end{pmatrix} & \quad &
      T_b = \begin{pmatrix}
        1 & 0 & 0 \\ 
        0 & 0 & 3 \\
        0 & \frac{1}{e^{14i\pi}} & 0 \\ 
      \end{pmatrix} & \quad &
    \end{aligned}
  \end{eqnarray} 


For aligned environments in Franklin you can use `\begin{eqnarray}...\end{eqnarray}` or `\begin{align}...\end{align}`.
One of the coolest Franklin features is in fact augmented markdown allowing definition of LaTeX-like commands!
Here's the code that produced the above math snippet.

```latex
\begin{eqnarray}
    \begin{aligned}
      o = \begin{pmatrix}
        2 & 1 & 1
      \end{pmatrix} & \quad &  
      T_a = \begin{pmatrix}
        1 & \frac{1}{3} & 1 \\ 
        0 & 0 & 0 \\
        0 & 0 & 0 \\ 
      \end{pmatrix} & \quad &
      T_b = \begin{pmatrix}
        1 & 0 & 0 \\ 
        0 & 0 & 3 \\
        0 & \frac{1}{e^{14i\pi}} & 0 \\ 
      \end{pmatrix} & \quad &
    \end{aligned}
\end{eqnarray} 
```

### Franklin and Latexify

[Latexify.jl](https://github.com/korsbo/Latexify.jl) is a Julia package that
thanks to
[homoiconicity](https://docs.julialang.org/en/v1/manual/metaprogramming/), can
convert Julia objects to LaTeX formatted strings.
Here's a demo from the Latexify.jl README.md file:

```julia:lx1
using Latexify
ex = :(x/(y+x)^2)
ls = latexify(ex; env=:eq)
println(ls.s) # hide
```

This generates a `LaTeXString` (from [LaTeXStrings.jl](https://github.com/stevengj/LaTeXStrings.jl)) which, when printed in the command line looks like:

```latex
$\frac{x}{\left( y + x \right)^{2}}$
```

And when this LaTeXString is displayed in an environment which supports the
`tex/latex` MIME type (Jupyter notebooks, Jupyterlab and Hydrogen for Atom, **and
Franklin.jl!**) it will automatically render as:

\textoutput{lx1}

```julia:lx2
using Latexify
arr = rand(ComplexF16, (2,2))
ls = latexify(arr) # this is an L string
println(ls.s) # hide
```

\textoutput{lx2}

Latexify also supports a lot of other mad types of data as input, for example, [DataFrames.jl](https://dataframes.juliadata.org/stable/) tables, and 
has macros so that you can typeset and run your 
code at the same type!

```julia:lx3
using Latexify 
ls = @latexrun f(x; y=2) = x/y
println(ls.s) # hide
```

\textoutput{lx3}

## Interactive plots with Plotly.jl

Franklin.jl supports interactive plots in the browser generated
from the Julia code in the Markdown code snippets! 
**How cool is this?**. You can read more [here](https://franklinjl.org/extras/plotly/)

@def hasplotly = true


```julia:ex2
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
```

\textoutput{ex2}

## Conclusion

[Franklin.jl](https://franklinjl.org/) opens up a world of 
opportunities for customization in SSGs and for web articles that involve a lot of literate programming and interactive plots!

It isn't all bells and whistles, Franklin.jl comes with some issues:
- No parsing of standard YAML frontmatter in `.md` files.
- Some features are not really well documented, had to look at [other Franklin.jl blogs](https://abhishalya.tech/)
- Sometimes, errors are cryptic and do not really explain what's happening
- I still have to figure out how to do decent date parsing in posts metadata.
- You have to do pagination by hand.

Otherwise, Franklin is a tiny gem! It took me just a few hours to move everything from the old Hugo website to this now SSG!
Something worth investigating in the future too, for literate programming, is that [Franklin.jl also supports Literate.jl](https://franklinjl.org/code/literate/), and this is how [Data Science Tutorials in Julia](https://alan-turing-institute.github.io/DataScienceTutorials.jl/) from the Alan Turing institute were written.

That's very cool and it's worth giving it a try!