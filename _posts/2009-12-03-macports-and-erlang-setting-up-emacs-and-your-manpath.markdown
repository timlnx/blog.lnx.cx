---
author: tbielawa
comments: true
date: 2009-12-03 03:32:05+00:00
layout: post
link: https://blog.lnx.cx/2009/12/02/macports-and-erlang-setting-up-emacs-and-your-manpath/
slug: macports-and-erlang-setting-up-emacs-and-your-manpath
title: 'Macports, and Erlang: Setting up Emacs and your $MANPATH'
wordpress_id: 101
categories:
- Emacs
- OS X
- Planet
- Programming
tags:
- Erlang
- Macports
- Manpath
---

You may find this helpful if you should find yourself using [Erlang](http://www.erlang.org/) on OS X and you've installed it using [Macports](http://www.macports.org). After a default installation you'll need to manually configure your .emacs file for **erlang-mode** and set your $MANPATH variable correctly, here's how.

If you've installed Erlang with Macports then you may have noticed that when you edit **.erl** files you're not entering into **erlang-mode**, nor is it available to enter into. Here's how I got [erlang-mode](http://www.erlang.org/doc/apps/tools/erlang_mode_chapter.html) working on my system.

Macports will install Erlang into /opt/local/lib/erlang by default. [The paths](http://www.erlang.org/doc/apps/tools/erlang_mode_chapter.html#id2261177) to put in your .emacs file provided in the erlang-mode documentation only need to be tweaked a slight bit to function properly. Here's what I put in mine:


    
    (setq load-path (cons  "/opt/local/lib/erlang/lib/tools-2.6.4/emacs/" load-path))
    (setq erlang-root-dir "/opt/local/lib/erlang")
    (setq exec-path (cons "/opt/local/bin" exec-path))
    (require 'erlang-start)



Note that you may require setting "tools-2.6.4" to something else if Macports has upgraded it's distribution of Erlang.

Setting up your $MANPATH variable is fairly simple as well. Just put the string "/opt/local/lib/erlang/man" in a file called 'erlang' in /etc/manpaths.d/ and make sure it ends with an empty line. Test this by opening a new terminal and running: **echo $MANPATH | grep erlang**. If it doesn't come back empty then you've done it right.
