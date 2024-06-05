---
author: tbielawa
comments: true
date: 2011-09-14 06:27:22+00:00
layout: post
link: https://blog.lnx.cx/2011/09/14/fedora-15-and-the-lenovo-t520-thinkpad/
slug: fedora-15-and-the-lenovo-t520-thinkpad
title: Fedora 15 and the Lenovo T520 Thinkpad
wordpress_id: 161
categories:
- Fedora
- GNU/Linux
- Planet
- Xorg
tags:
- fedora 14
- fedora 15
- kms
- laptop
- lenovo
- Linux
- T520
- thinkpad
- xorg
---

I just went through a harrowing experience of attempting to install Fedora 14 on a Lenovo T520 Thinkpad with my good friend, [abutcher](http://afrolegs.com). The issue presented itself first as X failing to start after the installer loaded. After switching into low graphics mode we were able to go through the installer successfully. But that did not solve our problems completely. After booting into the desktop we were unable to change the display resolution from 1280x1024 to the native 1600x900.

We started as most people would, Googling for numerous combinations of "fedora 14 thinkpad T520", "sandybridge linux", "sandybridge fedora", etc. The results were surprising. Numerous sources report the T520 works with "[no special setup needed](http://mo.morsi.org/blog/node/344)." This was not true for us. We Tried installing a newer Kernel from rawhide and the newer` xorg-x11-drv-intel` driver (2.16). This did not fix the issue.

To compound our confusion, we noticed numerous posts referencing a BIOS option to disable the Nvidia 4200M (Optimus) card. Our system showed no signs of said card or any "internal"/"external" BIOS option.

Next we attempted installing Fedora 15. *ugh* GNOME 3 was not on our list of things to try today. But it was all we could think of.

This also did not work.

I started doing some heavy research. Somehow I ended up researching Kernel Mode Setting (KMS). The [Debian Wiki](http://wiki.debian.org/KernelModesetting) was an especially useful resource for this.


<blockquote>Kernel Mode Setting (KMS) provides faster mode switching for X and console. It also provides native-resolution VTs on some laptops and netbooks which, prior to this, would use some standard mode, e.g. 800×600 on a 1024×600 panel.</blockquote>


This was relevant to my interests. "KMS provides native-resolution virtual terminals" you say? A quick trip to `/boot/grub/grub.conf` showed that **we were booting our kernel with the nomodeset option**. We made a new boot entry (protip: never change your boot loader without leaving a known "working" entry) and omitted the nomodeset option. We also set the value of the default variable to our new entry, set `timeout` to 10, and commented out the `hiddenmenu` directive.

This **almost** worked. We removed the xorg config file (`/etc/X11/xorg.conf`) and restarted the computer for good measure.

voila.

Our Lenovo Thinkpad T520 was booting X using the laptops native resolution.

Just to clarify:



	
  * Not ALL T520s come with the dual Intel Integrated Graphcs + Nvidia combination (ours did not)

	
  * This can really throw you off

	
  * The `xorg-x11-drv-nouveau` package/driver had nothing to do with this. That package provides an Nvidia driver (which did not affect us)

	
  * The `kmod-nvidia` package/driver also has nothing to do with this

	
  * This laptop has an integrated Intel HD 3000 Graphics chipset


