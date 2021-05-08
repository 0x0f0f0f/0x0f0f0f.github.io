using Dates

today = Dates.today()
curyear = year(today)
curmonth = month(today)
curday = day(today)

const HIDE_DRAFTS = if haskey(ENV, "HIDE_DRAFTS")
    parsed_var = Meta.parse(ENV["HIDE_DRAFTS"])
    parsed_var isa Bool && parsed_var
else false end

"""
    {{blogposts}}

Plug in the list of blog posts contained in the `/blog/` folder.
"""
function hfun_blogposts()
    list = readdir("blog")
    filter!(f -> endswith(f, ".md"), list)
    sorter(p) = begin
        ps  = splitext(p)[1]
        url = "/blog/$ps/"
        surl = strip(url, '/')
        pubdate = pagevar(surl, :published)
        # println(surl)
        # dump(pubdate)
        if isnothing(pubdate)
            return Date(Dates.unix2datetime(stat(surl * ".md").ctime))
        end
        return Date(pubdate, dateformat"d U Y")
    end
    sort!(list, by=sorter, rev=true)

    if HIDE_DRAFTS
        filter!(list) do p 
            ps  = splitext(p)[1]
            url = "/blog/$ps/"
            surl = strip(url, '/')
            isdraft = pagevar(surl, :draft)
            if isdraft !== nothing && isdraft
                @info "Skipping draft $surl"
                return false
            end
            return true
        end
    end

    io = IOBuffer()
    write(io, """<ul class="blog-posts">""")
    for (i, post) in enumerate(list)
        if post == "index.md"
            continue
        end
        ps  = splitext(post)[1]
        write(io, "<li><span><i>")
        url = "/blog/$ps/"
        surl = strip(url, '/')
        title = pagevar(surl, :title)
        pubdate = pagevar(surl, :published)
        if isnothing(pubdate)
            date    = "$curyear-$curmonth-$curday"
        else
            date    = Date(pubdate, dateformat"d U Y")
        end
        write(io, """$date</i></span><a href="$url">$title</a>""")
    end
    write(io, "</ul>")
    return String(take!(io))
end

"""
    {{custom_taglist}}

Plug in the list of blog posts with the given tag
"""
function hfun_custom_taglist()::String
    tag = locvar(:fd_tag)
    rpaths = globvar("fd_tag_pages")[tag]
    sorter(p) = begin
        pubdate = pagevar(p, :published)
        if isnothing(pubdate)
            return Date(Dates.unix2datetime(stat(p * ".md").ctime))
        end
        return Date(pubdate, dateformat"d U Y")
    end
    sort!(rpaths, by=sorter, rev=true)

    io = IOBuffer()
    write(io, """<ul class="blog-posts">""")
    # go over all paths
    for rpath in rpaths
        write(io, "<li><span><i>")
        url = get_url(rpath)
        title = pagevar(rpath, :title)
        pubdate = pagevar(rpath, :published)
        if isnothing(pubdate)
            # curyear = year(today)
            # curmonth = month(today)
            # curday = day(today)
        
            date    = "$curyear-$curmonth-$curday"
            # nothing
        else
            date    = Date(pubdate, dateformat"d U Y")
        end
        # write some appropriate HTML
        write(io, """$date</i></span><a href="$url">$title</a>""")
    end
    write(io, "</ul>")
    return String(take!(io))
end


"""
    {{custom_tagnum}}

Plug in the list of tags and the number of blogposts
"""
function hfun_custom_tagnum()::String
    # tag = locvar(:fd_tag)
    list = readdir("blog")
    filter!(f -> endswith(f, ".md"), list)

    if HIDE_DRAFTS
        filter!(list) do p 
            ps  = splitext(p)[1]
            url = "/blog/$ps/"
            surl = strip(url, '/')
            isdraft = pagevar(surl, :draft)
            if isdraft !== nothing && isdraft
                @info "Skipping draft $surl"
                return false
            end
            return true
        end
    end

    tag_pages = Dict()

    for p in list 
        ps  = splitext(p)[1]
        url = "/blog/$ps/"
        surl = strip(url, '/')
        tags = pagevar(surl, :tags)

        for tag in tags
            if !haskey(tag_pages, tag)
                tag_pages[tag] = 0
            end
            tag_pages[tag] += 1
        end
    end

    tag_pages = sort(collect(tag_pages), lt=(x,y) -> x[2] > y[2])

    io = IOBuffer()
    write(io, """<p class="tags">""")

    for (tag, num) in tag_pages
        url = "/tag/$tag"
        write(io, "<a href=\"$url\">#$tag</a> <span><i>($num)</i></span>; ")
    end

    write(io, "</p>")
    return String(take!(io))
end


"""
    {{post_header}}

Generate an appropriate header for the blogpost
"""
function hfun_post_header()::String
    io = IOBuffer()
    title = locvar(:title)
    write(io, "<h1>$title</h1>\n")
    date = locvar(:published)
    write(io, "<p>Published $date</p>\n")

    tags = locvar(:tags)
    if !isempty(tags)
        write(io, "<p><b>Tags: </b>")
        for (i, tag) in enumerate(tags)
            write(io, "<a href=\"/tag/$tag\">#$tag</a>")
            if i < length(tags)
                write(io, ", ")
            end
        end
    end
    write(io, "</p>")

    isdraft = locvar(:draft)
    if !isnothing(isdraft) && isdraft
        write(io, "<p><b>THIS ARTICLE IS A DRAFT!</b></p>\n")
    end
    write(io, "<hr/>\n")
    return String(take!(io))
end

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

