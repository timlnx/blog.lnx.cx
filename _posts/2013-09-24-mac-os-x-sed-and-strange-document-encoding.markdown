---
author: Tim Case
date: 2013-09-24 15:03:10+00:00
layout: post
title: Mac OS X, Sed, and strange document encoding
categories:
- OS X
- Planet
tags:
- LANG
- latin1
- locale
- Mac
- OS X
- sed
- utf8
- Windows-1252
---

# The Problem


You're on Mac OS X (somewhere around 10.7.5) and you're using the **sed** command to replace characters from the [latin1](http://en.wikipedia.org/wiki/Latin1) or [Windows-1252](http://en.wikipedia.org/wiki/Windows-1252) character encoding with their utf8 equivalents. Unfortunately you get an error like the following:


<blockquote>

>     
>     <code>sed: 1: "s/#/’/g
>     ": RE error: illegal byte sequence</code>
> 
> 
</blockquote>


Luckily you're not alone!



	
  * [vim_dev](https://groups.google.com/forum/?fromgroups#!topic/vim_dev/Bb6PAdwOpTc)

	
  * [homebre-deps](https://github.com/Homebrew/homebrew-dupes/pull/21)

	
  * [HamDecks](https://github.com/tbielawa/HamDecks/issues/4)

	
  * [stackoverflow](http://stackoverflow.com/questions/5709540/sed-unable-to-execute-some-commands-on-utf-8-encoded-chars)


This happened to me while working on [HamDecks](https://github.com/tbielawa/HamDecks), a small project that creates [Mnemosyne](http://www.mnemosyne-proj.org/) decks to help you study for the Amateur Radio Operator exams using questions from the official [ARRL Question pools](http://www.arrl.org/question-pools). The source question pool files ([Technician](http://www.ncvec.org/downloads/Revised%20Element%202.txt), [General](http://www.ncvec.org/downloads/Final%20Element%203%20Pool.txt), [Extra](http://www.ncvec.org/downloads/REVISED%20Extra%20Class%20Pool.txt)) though have some problems... There's a lot of characters with strange/exotic encoding in the ARRL pool files that could not be imported into Mnemosyne. That's how I got myself into this whole mess in the _first_ place.


# Options


The stackoverflow link above makes two suggestions:



	
  1. Use the **iconv** utility

	
  2. Use a PERL one-liner


_Your Mileage May Vary_, but neither of those suggestions worked for me. So what did work then?


# Potential Solution


Once again, we will [visit our system **locale** settings](http://blog.lnx.cx/2009/08/13/fixing-my-missing-locales/).

[Here's what worked](https://github.com/tbielawa/HamDecks/pull/5) for the HamDecks project:

https://gist.github.com/6685995

Instead of just prefixing the **sed** command with **LANG=C**, we prefix it with **LANG=C LANG_ALL=C**. I'm not saying this is a [_silver bullet_](http://en.wikipedia.org/wiki/No_Silver_Bullet), just that it worked for me and might work for you too.
