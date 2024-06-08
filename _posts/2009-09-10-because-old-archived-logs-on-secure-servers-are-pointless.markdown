---
author: ajfarrell
date: 2009-09-10 04:33:59+00:00
layout: post
title: Because old archived logs on secure servers are pointless...
categories:
- GNU/Linux
- OS X
- Tutorials
---

Often we get Nagios alerts letting us know that your kernel is about to panic and your server is going to crash and die because read/write operations are going to FAIL MISERABLY.

Obviously being a systems administrator it becomes your job to figure out what can go, what needs to stay, et al.

I've found that archived logs (logrotate) on a secure server often can be quite large. And on a low-end configuration with a server with only 40G it becomes a nuisance when you have a few Gb of data...
And you all probably know this, but Tim asked when I'd blog. So... I'll make sure!
Having 40 or 50 files is a pain to manually delete. Sure, you could probably rm -f *.1 *.2 *.3 etc etc etc but that becomes too much of a pain.

On BSD systems there is an awesome counter called 'jot'; it works exactly the opposite of the GNU command 'seq'; so for a rudimentary example to remove all files it becomes a simple one liner--



	
  * jot 6 1 |while read i; do rm -f *.${i};done

	
  * seq 1 6|while read i; do rm -f *.${i};done


In Emeril fashion: BAM! You're now out of the clear.
