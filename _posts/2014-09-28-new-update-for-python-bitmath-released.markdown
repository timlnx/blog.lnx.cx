---
author: tbielawa
comments: true
date: 2014-09-28 20:38:05+00:00
layout: post
link: https://blog.lnx.cx/2014/09/28/new-update-for-python-bitmath-released/
slug: new-update-for-python-bitmath-released
title: New update for python-bitmath released
wordpress_id: 596
categories:
- Fedora
- Planet
- Programming
tags:
- bitmath
- Fedora
- library
- math
- module
- nist
- package
- prefix units
- pypi
- Python
- release
- si
---

bitmath-1.0.8-1 was published on 2014-08-14.


# Major Updates





	
  * bitmath has a proper documentation website up now on Read the Docs, check it out:

	
    * [bitmath.readthedocs.org](http://bitmath.readthedocs.org/en/latest/)




	
  * bitmath is now Python 3.x compatible

	
  * bitmath is now included in the [Extra Packages for Enterprise Linux](https://fedoraproject.org/wiki/EPEL) [EPEL6](http://dl.fedoraproject.org/pub/epel/6/x86_64/repoview/python-bitmath.html) and [EPEL7](http://dl.fedoraproject.org/pub/epel/7/x86_64/repoview/python-bitmath.html)repositories

	
  * merged 6 [pull requests](https://github.com/tbielawa/bitmath/pulls?q=is%3Apr+closed%3A%3C2014-08-28) from 3 [contributors](https://github.com/tbielawa/bitmath/graphs/contributors)




## Bug Fixes





	
  * fixed some math implementation bugs

	
    * [commutative multiplication](https://github.com/tbielawa/bitmath/issues/18)

	
    * [true division](https://github.com/tbielawa/bitmath/issues/2)







## Changes


**Added Functionality**



	
  * [best-prefix](http://bitmath.readthedocs.org/en/latest/instances.html#best-prefix) guessing: automatic best human-readable unit selection

	
  * support for [bitwise operations](http://bitmath.readthedocs.org/en/latest/simple_examples.html#bitwise-operations)

	
  * [formatting customization](http://bitmath.readthedocs.org/en/latest/instances.html#format) methods (including plural/singular selection)

	
  * exposed many more [instance attributes](http://bitmath.readthedocs.org/en/latest/instances.html#instances-attributes) (all instance attributes are usable in custom formatting)

	
  * a [context manager](http://bitmath.readthedocs.org/en/latest/module.html#bitmath-format) for applying formatting to an entire block of code

	
  * utility functions for sizing [files](http://bitmath.readthedocs.org/en/latest/module.html#bitmath-getsize) and [directories](http://bitmath.readthedocs.org/en/latest/module.html#bitmath-listdir)

	
  * add [instance properties](http://bitmath.readthedocs.org/en/latest/instances.html#instance-properties) equivalent to **instance.to_THING()** methods




## Project


**Tests**



	
  * Test suite is now implemented using [Python virtualenv’s](https://github.com/tbielawa/bitmath/blob/master/Makefile#L177) for consistency across across platforms

	
  * Test suite now contains **150** unit tests. This is **110** more tests than the previous major release ([_1.0.4-1_](http://bitmath.readthedocs.org/en/latest/NEWS.html#bitmath-1-0-4-1))

	
  * Test suite now runs on EPEL6 and EPEL7

	
  * [Code coverage](https://coveralls.io/r/tbielawa/bitmath?branch=master) is stable around 95-100%




### Examples Below the Fold


<!-- more -->


# Examples


https://gist.github.com/tbielawa/f949de30012a5657000f
