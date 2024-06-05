---
author: tbielawa
comments: true
date: 2011-10-15 19:19:11+00:00
layout: post
link: https://blog.lnx.cx/2011/10/15/mac-os-x-10-7-getting-songs-off-an-ipod/
slug: mac-os-x-10-7-getting-songs-off-an-ipod
title: Mac OS X 10.7 - Getting songs off an iPod
wordpress_id: 165
categories:
- OS X
- Planet
tags:
- Backup
- iPod
- iPodDisk
- iTunesFS
- MacFuse
- Music
- OS X
- OS X Fuse
---

A while back I wanted to backup the songs I've saved to my [iPod](http://www.apple.com/ipodclassic/). I was running [Mac OS X Leopard](http://en.wikipedia.org/wiki/Mac_OS_X#Versions) (10.5). When I searched around I found a tool called [iPodDisk](http://code.google.com/p/ipoddisk/). It worked great! Then Snow Leopard (10.6) came out.

The way the launcher for iPodDisk was written meant it only would launch on 10.4 or 10.5. When you launched iPodDisk you would receive the message:


<blockquote>"Sorry iPodDisk requires OS X 10.4 or later"</blockquote>


Fixing this was pretty simple. After searching their [google code issue tracker](http://code.google.com/p/ipoddisk/issues/list) I quickly came across issue #34, "[Sorry iPodDisk requires OS X 10.4 or later](http://code.google.com/p/ipoddisk/issues/detail?id=34)". The fix was simple, [reply #3](http://code.google.com/p/ipoddisk/issues/detail?id=34#c3) in the thread said to just edit one line in the launcher so that the version check accepted a higher version.

Time goes on and eventually I did a full OS reinstall (for some reason or another) and just recently upgraded to 10.7 (Lion). I'd bought a new network storage unit ([Western Digital My Book Live](http://www.wdc.com/en/products/products.aspx?id=280)) and wanted to back up my iPod again. Of course, upon downloading and launching iPodDisk again it produced the same error it did previously. It was clear to me that iPodDisk was clearly not being maintained.

While searching for the fix again I decided to read some newer posts on the issue tracker. [Reply #51](http://code.google.com/p/ipoddisk/issues/detail?id=34#c51) referenced [MacFuse](http://code.google.com/p/macfuse/). The project site for that hasn't made a new release since 2008 though. [Reply #60](http://code.google.com/p/ipoddisk/issues/detail?id=34#c60) had the information I was finally looking for.

So the final solution that allowed me to backup my iPod on OS X 10.7, Lion, was to install these two pieces of software:



	
  * [iTunesFS](http://www.mulle-kybernetik.com/znek/public/en/default/software/iTunesFS/index.html)

	
  * [OSX Fuse](http://osxfuse.github.com/)




The result was perfect. The same functionality I had when using iPodDisk previously. When you launch iTunesFS it opens a new Finder window showing all mounted volumes. Navigate to the iTunesFS volume and you're set.
