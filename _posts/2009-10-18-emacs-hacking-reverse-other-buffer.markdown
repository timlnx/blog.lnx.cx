---
author: Tim Case
date: 2009-10-18 22:39:51+00:00
layout: post
title: Emacs Hacking, reverse other buffer
categories:
- Emacs
- Planet
- Programming
tags:
- Emacs
- lisp
---

I started reading _Writing GNU Emacs Extensions_ by Bob Glickstein. The first real meaty example you work through in it is making an 'other-buffer' like key command that works in reverse. So here I present to the internet, my version of previous-window.


    
    
    (defun previous-window ()
      "As other-buffer, except in the other-direction"
      (interactive)
      (other-window -1))
    
    (global-set-key "\C-c\o" 'previous-window)
    



Put in your **.emacs** file and activate with **C-c o** when you have multiple frames open at once.
