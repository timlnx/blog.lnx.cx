---
author: Tim Bielawa
date: 2016-07-03 13:59:07+00:00
layout: post
title: bitmath - Now available in Ubuntu PPAs
categories:
- Fedora
- GNU/Linux
- Planet
- Ubuntu
tags:
- bitmath
- packaging
- pypi
- Python
- ubuntu
---

[![ubuntu-logo32](https://blog.lnx.cx/wp-content/uploads/2016/07/ubuntu-logo32.png)](https://blog.lnx.cx/wp-content/uploads/2016/07/ubuntu-logo32.png)

[bitmath](http://bitmath.readthedocs.io/en/latest/) is a Python module I wrote for working with file size units (ex: `12GiB`, `64kB`) as objects. You can use them just like you would use regular numbers in python. It's full of other functionality as well. Objects have native 'convert to _$unit_' methods, support native arithmetic, are sortable, and include a 'best human readable prefix' method.

Since [March 2014](https://blog.lnx.cx/2014/03/27/python-bitmath-now-available-in-fedora/), bitmath had only been available via [PyPi](https://pypi.python.org/pypi/bitmath/) and [Fedora/EPEL repositories](http://koji.fedoraproject.org/koji/packageinfo?packageID=18246). **Now**, as of July 2nd 2016, bitmath is natively available to Ubuntu users by means of a new Personal Package Archive ([PPA](https://launchpad.net/~tbielawa/+archive/ubuntu/bitmath)) hosting bitmath builds for Xenial, Wily, Vivid, Trusty, and Precise.

Ubuntu users can install bitmath in the following way:

https://gist.github.com/tbielawa/e2bf299e2b9af239542fe6f4dbd57756

Ubuntu support wouldn't have happened if GitHub user [hkraal](https://github.com/hkraal) hadn't submitted an [issue](https://github.com/tbielawa/bitmath/issues/57). Thanks Henk for getting the [fire lit](https://github.com/tbielawa/bitmath/issues/58)!



 	
  * Check out [bitmath on GitHub](https://github.com/tbielawa/bitmath)


