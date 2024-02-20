<!--
Add here global page variables to use throughout your
website.
The website_* must be defined for the RSS to work
-->
@def website_title = "0x0f0f0f - Alessandro Cheli"
@def website_descr = "Bits and bubbles and writings"
@def website_url   = "https://chelidev"
@def git_url = "https://github.com/0x0f0f0f"
<!-- @def twitter_url = "https://twitter.com/0x0f0f0f1" -->

@def author = "Alessandro Cheli"

@def mintoclevel = 2

<!-- Stuff related to the site styling -->
@def div_content = "container"

@def hasplotly = false


<!--
Add here files or directories that should be ignored by Franklin, otherwise
these files might be copied and, if markdown, processed by Franklin which
you might not want. Indicate directories by ending the name with a `/`.
-->
+++
hidedrafts = if haskey(ENV, "HIDE_DRAFTS")
    parsed_var = Meta.parse(ENV["HIDE_DRAFTS"])
    parsed_var isa Bool && parsed_var
else false end
ignore = if hidedrafts
        ["node_modules/", "franklin", "franklin.pub", "drafts/"]
    else
        ["node_modules/", "franklin", "franklin.pub"]
    end

navbar_items = ["Home" => "/", "Blog" => "/blog", "Tags" => "/tag/"]
generate_rss = true
+++

<!--
Add here global latex commands to use throughout your
pages. It can be math commands but does not need to be.
For instance:
* \newcommand{\phrase}{This is a long phrase to copy.}
-->
\newcommand{\R}{\mathbb R}
\newcommand{\scal}[1]{\langle #1 \rangle}
