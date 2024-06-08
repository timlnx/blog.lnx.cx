---
author: Tim Bielawa
date: 2011-03-25 06:35:40+00:00
layout: post
title: Them's the rules (programming guidelines)
categories:
- /dev/null
- Planet
- Programming
---

In the future I hope to expand on this list. In general though, strive to follow [the basics of the Unix Philosophy.](http://www.catb.org/~esr/writings/taoup/html/ch01s06.html)





# Law of Demeter


You should only know what your close friends tell you - [http://en.wikipedia.org/wiki/Law_of_Demeter](http://en.wikipedia.org/wiki/Law_of_Demeter)



	
  * Each unit should have only limited knowledge about other units: only units "closely" related to the current unit.

	
  * Each unit should only talk to its friends; don't talk to strangers.

	
  * Only talk to your immediate friends.




# Principle of least astonishment


Boring behavior is the new exciting - [http://en.wikipedia.org/wiki/Principle_of_least_astonishment](http://en.wikipedia.org/wiki/Principle_of_least_astonishment)



	
  * "...when two elements of an interface conflict, or are ambiguous, the behaviour should be that which will least surprise the user..."




# The "UNIX Way"


(Doing) less is more - [http://www.faqs.org/docs/artu/ch01s06.html](http://www.faqs.org/docs/artu/ch01s06.html)



	
  * Write programs that do one thing and do it well.




# Make good with what you're given, complain if you can't


Rule of Repair: Repair what you can — but when you must fail, fail noisily and as soon as possible [http://www.catb.org/~esr/writings/taoup/html/ch01s06.html#id2878538](http://www.catb.org/~esr/writings/taoup/html/ch01s06.html#id2878538)



	
  * Be liberal in what you accept, and conservative in what you send


