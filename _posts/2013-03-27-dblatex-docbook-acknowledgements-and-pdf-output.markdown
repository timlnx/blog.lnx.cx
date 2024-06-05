---
author: tbielawa
comments: true
date: 2013-03-27 15:15:23+00:00
layout: post
link: https://blog.lnx.cx/2013/03/27/dblatex-docbook-acknowledgements-and-pdf-output/
slug: dblatex-docbook-acknowledgements-and-pdf-output
title: dblatex, DocBook, acknowledgements and PDF output
wordpress_id: 276
categories:
- DocBook
- Documentation
- GNU/Linux
- Planet
- Publishing
- XML
---

In the book I'm working on, the [Virtual Disk Guide](https://github.com/tbielawa/Virtual-Disk-Guide), I recently decided to start templating out an [Acknowledgements](http://docbook.org/tdg5/en/html/acknowledgements.html) chapter. I'm writing the book in [DocBook5](http://docbook.org/) and my print (PDF) publishing toolchain looks like this:



 	
  1. GNU Make

 	
  2. xsltproc

 	
  3. [dblatex](http://dblatex.sourceforge.net)


The problem I ran into is that dblatex has no stylesheets or templates built in to handle DocBook acknowledgements elements and the PDF is difficult to manage, but systems like [sodapdf](https://www.sodapdf.com/) could be the perfect solution for this. Acknowledgements sections should be fairly simple to render I thought. You really just need a chapter header, and then to process the block elements, like paragraphs, blockquotes, and what have you. To me, the same template used for [Colophon](http://docbook.org/tdg5/en/html/colophon.html) sections would create an ideal acknowledgements section.

I've never done any real XSLT work before, and even after this I still wouldn't claim that I have, but here's what I did to get a working acknowledgements section:

I found the location dblatex installs it's XSL documents to on my system, `/usr/share/dblatex/xsl`, then I used grep to find files that matched `colophon` elements: `grep colophon *.xsl`. Examining the `component.xsl` file suggested that it had the templates I needed to copy and modify for feeding into dblatex. After a few attempts I came up with working results. Here's what it ends up looking like:

https://gist.github.com/5254805

And you consume it with dblatex in this way:

https://gist.github.com/5254884

For an example of how this renders you can look at [the PDF version](http://lnx.cx/docs/vdg/output/Virtual-Disk-Operations.pdf) of the Virtual Disk Guide. I keep the file in version control [on the github project](https://github.com/tbielawa/Virtual-Disk-Guide/blob/master/xsl/dblatex-acknowledgements.xsl) for the book.

Speaking of **Acknowledgements**: Thanks to my buddy Al for dusting off his XSLT skills and debugging this with me initially.
