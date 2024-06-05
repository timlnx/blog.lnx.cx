---
author: tbielawa
comments: true
date: 2009-08-13 21:38:46+00:00
layout: post
link: https://blog.lnx.cx/2009/08/13/enabling-automatic-slash-completion-in-nxml-mode/
slug: enabling-automatic-slash-completion-in-nxml-mode
title: Enabling automatic slash completion in nXML-Mode
wordpress_id: 12
categories:
- Emacs
- Planet
tags:
- DocBook
- Emacs
- nXML-Mode
- XML
---

I do a lot of DocBook XML editing, either at my job or at home. Because of that I've built up a pretty customized .emacs file. Every so often I meet another person whose also found themselves having to edit a bunch of XML. The most fantastic thing about nXML mode I think is the automatic slash completion feature. It works like this: If I have an open element, say I've started an <xref>, you can configure nXML mode such that upon typing the closing </ characters it will complete that sequence for you. I can just never remember how to set that option in emacs. So today I'm taking the time to finally document that procedure.



	
  1. Enter nxml-mode

	
  2. **M-x** customize-apropos

	
  3. nxml-slash

	
  4. Press Toggle on

	
  5. Optionally: select "Save for future sessions"


For even more fun, use the **C-c C-f** macro which will auto complete your current block, regardless of your position inside of it. For additional references, I invite you to check out the docs [NM Tech](http://infohost.nmt.edu/tcc/help/pubs/nxml/markup-commands.html) has posted on nXML-Mode.
