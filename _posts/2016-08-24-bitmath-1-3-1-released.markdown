---
author: Tim Bielawa
date: 2016-08-24 16:33:03+00:00
layout: post
title: bitmath-1.3.1 released
categories:
- Planet
- Programming
tags:
- bitmath
- Fedora
- module
- project
- Python
---

[bitmath](http://bitmath.readthedocs.io/en/latest/) is a Python module I wrote which simplifies many facets of interacting with file sizes in various units as python objects. A few weeks ago version 1.3.1 was released with a few small updates.


# Updates





 	
  * **New function**: [bitmath.parse_string_unsafe()](http://bitmath.readthedocs.io/en/latest/module.html#bitmath.parse_string_unsafe), a less strict version of [bitmath.parse_string()](http://bitmath.readthedocs.io/en/latest/module.html#bitmath.parse_string)


This new function accepts inputs using non-standard prefix units such as single-letter, or mis-capitalized units. For example, `parse_string` will not accept a short unit like '**100k**', whereas `parse_string_unsafe` will gladly accept it:

https://gist.github.com/tbielawa/2fdc7fa45d6a5cf6d8d6da9324a12b98



 	
  * **Documentation Refresh**: The project documentation has been thoroughly reviewed and refreshed.


Several broken, moved, or redirecting links have been fixed. Wording and examples are more consistent. The documentation also lands correctly when installed via package.


# Getting bitmath-1.3.1


bitmath-1.3.1 is available through several installation channels:



 	
  * Fedora 23 and newer repositories

 	
  * [EPEL](https://fedoraproject.org/wiki/EPEL) 6 and 7 repositories

 	
  * [PyPi](https://pypi.python.org/pypi/bitmath/)


Ubuntu builds have not been prepared yet due to issues I've been having with Launchpad and new package versions.
