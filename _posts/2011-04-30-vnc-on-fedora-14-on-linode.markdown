---
author: tbielawa
comments: true
date: 2011-04-30 05:19:26+00:00
layout: post
link: https://blog.lnx.cx/2011/04/30/vnc-on-fedora-14-on-linode/
slug: vnc-on-fedora-14-on-linode
title: VNC On Fedora 14 on Linode
wordpress_id: 158
categories:
- Fedora
- Planet
---

Installed and configured tigervnc on my Linode host today, had a nasty problem getting fonts to display though. After KDE had loaded only the fixed width font used by vncconfig was showing, the rest were empty squares. Here's what didn't work on my Fedora 14 host:



	
  * xorg-x11-fonts-misc-7.2-12.fc14.noarch

	
  * 1:xorg-x11-xfs-1.0.5-8.fc14.x86_64

	
  * xorg-x11-server-Xvfb-1.9.5-1.fc14.x86_64


I contribute this to my lacking of any knowledge of what fonts KDE tries to use by default. After some googling I got lucky and found this thread where someone suggests the original poster install the liberation family of fonts. That ended up being what fixed the problem for me.
