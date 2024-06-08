---
author: Tim Bielawa
date: 2016-02-04 02:08:24+00:00
layout: post
title: bitmath-1.3.0 released
categories:
- Fedora
- GNU/Linux
- Planet
- Programming
tags:
- bitmath
- Fedora
- module
- project
- Python
- update
---

It's been quite a while since I've posted any [bitmath](https://bitmath.readthedocs.org/en/latest/index.html) updates (bitmath is a Python module I wrote which simplifies many facets of interacting with file sizes in various units as python objects) . In fact, it seems that the last time I wrote about bitmath here was [back in 2014](https://blog.lnx.cx/2014/09/28/new-update-for-python-bitmath-released/) when 1.0.8 was released! So here is an update covering everything post 1.0.8 up to 1.3.0.


# New Features





	
  * A command line tool, `bitmath`, you can use to do simple conversions right in your shell [[docs](http://bitmath.readthedocs.org/en/latest/commandline.html)]!

	
  * New utility function [bitmath.parse_string](http://bitmath.readthedocs.org/en/latest//module.html#bitmath-parse-string) for parsing a human-readable string into a bitmath object

	
  * New utility: [argparse](https://docs.python.org/2/library/argparse.html) integration: [bitmath.BitmathType](https://bitmath.readthedocs.org/en/latest/module.html#argparse). Allows you to specify arguments as bitmath types

	
  * New utility: [progressbar](https://github.com/niltonvolpato/python-progressbar) integration: [bitmath.integrations.BitmathFileTransferSpeed](http://bitmath.readthedocs.org/en/latest/module.html#progressbar). A more functional file transfer speed widget

	
  * New bitmath module function: [bitmath.query_device_capacity()](https://bitmath.readthedocs.org/en/latest/module.html#bitmath.query_device_capacity). Create bitmath.Byte instances representing the capacity of a block device

	
    * This _my favorite enhancement_

	
    * In an upcoming  blog post I'll talk about just how cool I thought it was _learning how to code_ this feature

	
    * Conceptual and practical implementation topics included




	
  * The [bitmath.parse_string()](https://bitmath.readthedocs.org/en/latest/module.html#bitmath.parse_string) function now can parse ‘octet’ based units

	
    * Enhancement requested in [#53 parse french unit names](https://github.com/tbielawa/bitmath/issues/53) by [walidsa3d](https://github.com/walidsa3d).




	
  * New utility function: [bitmath.best_prefix()](http://bitmath.readthedocs.org/en/latest/instances.html#best-prefix)

	
    * Return an equivalent instance which uses the best human-readable prefix-unit to represent it

	
    * This is way cooler than it may sound at the surface, I **promise** you







# Bug Fixes





	
  * [#49](https://github.com/tbielawa/bitmath/pull/49) - Fix handling unicode input in the bitmath.parse_string function. Thanks [drewbrew](https://github.com/drewbrew)!

	
  * [#50](https://github.com/tbielawa/bitmath/pull/50) - Update the setup.py script to be python3.x compat. Thanks [ssut](https://github.com/ssut)!

	
  * [#55](https://github.com/tbielawa/bitmath/pull/55) “best_prefix for negative values”. Now bitmath.best_prefix() returns correct prefix units for negative values. Thanks [mbdm](https://github.com/mbdm)!




# Misc


To help with the [Fedora Python3 Porting project](https://fedoraproject.org/wiki/FAD_Python_3_Porting_2015), bitmath now comes in two variants in Fedora/EPEL repositories ([BZ1282560](https://bugzilla.redhat.com/show_bug.cgi?id=1282560)). The Fedora and EPEL updates are now in the repos. **TIP:** `python2-bitmath` will obsolete the `python-bitmath` package. Do a `dnf`/`yum` '`update`' operation just to make sure you catch it.

[The PyPi release](https://pypi.python.org/pypi/bitmath) has already been pushed to stable.

Back in bitmath-1.0.8 we had _150_ unit tests. The latest release has almost **200**! Go testing! `:confetti:`
