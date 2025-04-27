---
author: Tim Case
date: 2012-01-04 03:29:51+00:00
layout: post
title: Excluding in the Emacs file completion buffer
categories:
- Emacs
- Planet
tags:
- completion
- elisp
- Emacs
- exclude
- filter
- stackoverflow
---

I realized tonight While hacking on [Taboot](http://fedorahosted.org/Taboot) that Emacs was showing particularly_ uninteresting _files in the completion buffer when opening a file. For example, `scripts.pyc`.

I assumed that there was a facility for customizing this, so I did some research on the topic. Trying _emacs filter possible completions_ and _emacs filter list of completions_ both came up with [the same documentation](http://www.gnu.org/software/emacs/manual/html_node/elisp/File-Name-Completion.html). The GNU documentation describes a customization facility similar to the filtering I sought after via the `completion-ignored-extensions` variable (part of the Dired group). However, it stops a bit short of what I was looking for. Quote from `describe-variable` for the variable (emphasis added):

    
    Completion ignores file names ending in any string in this list. It does not ignore them if all possible completions end in one of these strings <strong>or when displaying a list of completions.</strong>


I went through some more search results and sure enough, [stackoverflow provides again](http://stackoverflow.com/a/1732081/263969). In that response the author provided a fantastic `defadvice` which did exactly what I was looking for. By default it uses the value of your existing `completion-ignored-extensions` variable.
