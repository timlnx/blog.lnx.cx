---
author: tbielawa
comments: true
date: 2012-04-02 16:47:54+00:00
layout: post
link: https://blog.lnx.cx/2012/04/02/setting-your-emacsens-default-directory-when-launched-through-a-custom-keyboard-shortcut/
slug: setting-your-emacsens-default-directory-when-launched-through-a-custom-keyboard-shortcut
title: Setting your Emacsens default directory when launched through a custom keyboard
  shortcut
wordpress_id: 133
categories:
- Emacs
- Planet
tags:
- default-directory
- Emacs
- gnome 2
---

I noticed that Emacs was getting a `default-directory` value of `/` when launching it with a custom keyboard shortcut I set up in Gnome (2). The result is that opening a file started my search in the root (`/`) of the filesystem.

I suppose this is due to the way in which emacs was invoked (via the window manager). Given that there was no actual _present working directory_, I can understand that it would default back to using `/`.

At the time I was just setting the window title:

    
    emacs -T Emacs


When considering how to work around this I first considered setting the `default-directory` in my `.emacs` file. This turned out to be a less an idea solution. Doing so causes it to become a global configuration value (all subsequent emacs launched via the terminal opened in `~`). So instead, I changed my launcher command to this:

    
    emacs -T Emacs -eval "(setq default-directory \"~/\")"


Works like a champ!
