---
author: Tim Bielawa
date: 2010-02-03 05:08:37+00:00
layout: post
title: Macports updates their Erlang version, update your load-path's
categories:
- Emacs
- Planet
- Programming
tags:
- Emacs
- Erlang
- XMPP
---

I've been working on my [XMPP server](http://github.com/tbielawa/PAD-XMPP) pet project recently, and the need for a good Erlang XML parser has finally struck. I decided to go with [Erlsom](http://erlsom.sourceforge.net/). It's in MacPorts, so from there I installed it. Now, since I  don't update my port tree frequently I get delightful surprises from time to time. This time installing Erlsom triggered an update of Erlang, to the latest version!

Short story shorter, the update changes the path to the erlang-mode.el file so before you can M-x erlang-mode again you'll have you fix your Emacs load-path to register the new location. (See my older post on how to initially [set up Erlang and Emacs](http://blog.peopleareducks.com/2009/12/02/macports-and-erlang-setting-up-emacs-and-your-manpath/) from MacPorts from scratch)

The new load commands should be:


    
    
    (setq load-path (cons  "/opt/local/lib/erlang/lib/tools-2.6.5/emacs/" load-path))
    (setq erlang-root-dir "/opt/local/lib/erlang")
    (setq exec-path (cons "/opt/local/bin" exec-path))
    (require 'erlang-start)
    



It just requires changing the tools-x.x.x to 2.6.5.

p.s. [about erlang-mode ](http://ftp.sunet.se/pub/lang/erlang/doc/man/erlang.el.html)
