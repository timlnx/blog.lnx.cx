---
author: Tim Case
date: 2010-03-27 01:00:48+00:00
layout: post
title: Zone out completely
categories:
- Emacs
- Planet
tags:
- Emacs
---

While searching for modes which would help me edit [bind9](http://www.bind9.net/) configuration files I came across [this mailing list post](https://lists.isc.org/pipermail/bind-users/2008-September/073061.html). It mentions `zone-mode` which ended up being great for editing the actual zone files A+. It also tipped me off to another emacs Easter Egg, `M-x zone`. Described thus:

    
    zone is an interactive compiled Lisp function.
    It is bound to    .
    (zone)
    Zone out, completely.


It's basically an emacs screensaver/psychedelic ascii mode using your focused buffer for content. It obfuscates the buffer in ways which involves wrapping your code around the screen or swapping characters around, and even just turning it all into curly braces and wiggling. Press a key to undo it all. Might be a neat trick to play on a friend, but I see no other usage for this mode.
