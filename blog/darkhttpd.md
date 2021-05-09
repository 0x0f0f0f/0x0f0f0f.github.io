@def title = "darkhttpd : you'll love static"
@def rss =  "darkhttpd : you'll love static"
@def published = "31 January 2019"
@def tags = ["foss", "good-stuff"]

{{post_header}}

[darkhttpd](https://unix4lyfe.org/darkhttpd/) - [wiki](https://wiki.alpinelinux.org/wiki/Darkhttpd) is my
favorite web server. It does one thing and it does it good: serve static files correctly.

The overall best feature I've found in **darkhttpd** is that it is configured via command line arguments, so you can wrap 
the configuration of each one of your web servers into it's **runit/OpenRC** service!

Running a static webserver will help you reduce overhead and lets you reduce the resource usage of your services.

You can easily install it by running:

**In [Void Linux](https://voidlinux.org):**
```
# xbps-install -S darkhttpd
```

**In [Alpine Linux](https://alpinelinux.org):**
```
# apk add darkhttpd
```

