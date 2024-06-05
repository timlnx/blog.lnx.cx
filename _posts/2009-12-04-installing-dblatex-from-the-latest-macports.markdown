---
author: tbielawa
comments: true
date: 2009-12-04 09:05:38+00:00
layout: post
link: https://blog.lnx.cx/2009/12/04/installing-dblatex-from-the-latest-macports/
slug: installing-dblatex-from-the-latest-macports
title: Installing dblatex from the latest MacPorts
wordpress_id: 107
categories:
- OS X
- Planet
tags:
- dblatex
- Macports
- Python
---

I ran into this issue while installing dblatex (0.2.10) from the most recent MacPorts tree today:


    
    
    Traceback (most recent call last):
      File "/opt/local/bin/dblatex", line 16, in <module>
        from dbtexmf.dblatex import dblatex
    ImportError: No module named dbtexmf.dblatex
    



I got past it by exporting `PYTHONPATH=/opt/local/Library/Frameworks/Python.framework/Versions/2.6/lib/python2.6/site-packages`, but clearly this was not optimal. I was about to file a bug report about the issue but before I did that I read their [new ticket guidelines](http://guide.macports.org/#project.tickets) which requested the full build log be included in the ticket.

In the build log was the solution. I would have missed it had my shell scrollback not been set to unlimited. Nestled a good 182 lines back in my buffer was this little message:


    
    
    --->  Installing python26 @2.6.4_0+darwin
    --->  Activating python26 @2.6.4_0+darwin
    
    To fully complete your installation and make python 2.6 the default, please run
    
    sudo port install python_select
    sudo python_select python26
    



I did as instructed, and sure enough, dblatex started working! I just wanted to post this on the blog in case anyone else ran into this and missed it like I did.
