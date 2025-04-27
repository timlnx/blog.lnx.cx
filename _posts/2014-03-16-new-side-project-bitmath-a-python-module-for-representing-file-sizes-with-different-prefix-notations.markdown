---
author: Tim Case
date: 2014-03-16 23:23:01+00:00
layout: post
title: 'New side-project: bitmath - A Python module for representing file sizes with
  different prefix notations'
categories:
- Fedora
- GNU/Linux
- Planet
- Programming
---

**Update: **[2014-03-27 - python-bitmath is now in Fedora!](https://blog.lnx.cx/2014/03/27/python-bitmath-now-available-in-fedora/)


# Background


I've written a new Python module which I'm calling [**bitmath**](https://github.com/tbielawa/bitmath).

Given my day job as a System Administrator, and the content of my [upcoming book](http://lnx.cx/docs/vdg/output/Virtual-Disk-Operations.pdf) on Linux virtual disks, I frequently find myself in situations requiring me to convert file sizes into various other formats. I recall far too many instances of having to do unit conversions mid-code in projects (_does this look familiar to anyone else?):_

https://gist.github.com/tbielawa/9590427

Thus, out of necessity, **bitmath** was born.


# bitmath


I'm going to plagiarize myself here and rip the long description right from the project:


<blockquote>**bitmath** simplifies many facets of interacting with file sizes in various units. Examples include: converting between SI and NIST prefix units (GiB to kB), converting between units of the same type (SI to SI, or NIST to NIST), basic arithmetic operations (subtracting 42KiB from 50GiB), and rich comparison operations (1024 Bytes == 1KiB).

In addition to the conversion and math operations, **bitmath** provides human readable representations of values which are suitable for use in interactive shells as well as larger scripts and applications.</blockquote>


Anyone not deeply invested in the heartache that comes with converting base-2 and base-10 prefix units can stop reading now.


# Why Should You Care?




## bitmath is Pythonic


**bitmath** finally provides a uniform way to manipulate these units in a way which is natural to Python programmers. There's nothing special or unusual required to work with **bitmath objects**. You can add them, subtract them, multiply and divide them -- just like you're already used to with the **int** and **float** objects. **bitmath objects** support all of the standard [Rich Comparison Operators](http://docs.python.org/2/reference/datamodel.html#object.__lt__) as well!

https://gist.github.com/tbielawa/9591035


## bitmath converts anything


Converting **bitmath objects** is a first-class supported operation. Even more complex conversions, like converting from Mibibits to Kilobytes, is trivial. This functionality is supported in both directions: from the lowliest **Bit()** object through the grand **EiB()** object. That is to say, any **bitmath object**, whether it be base-2 ([NIST 'kibi' and 'gibi' style](http://physics.nist.gov/cuu/Units/binary.html)) or base-10 ([SI 'kilo' and 'giga' style](http://physics.nist.gov/cuu/Units/prefixes.html)), supports conversion (without loss of accuracy) to any other valid prefix unit.**
**

https://gist.github.com/tbielawa/9591150


## **bitmath objects** print out nicely


As the previous two examples demonstrated, **bitmath objects** have useful console representations, as well as string representations. In a future release the format string for this may be configurable.


# Getting **bitmath**


Fedora/RHEL6 users will need to wait a bit longer for a proper **yum install** command to be available, as the package <del>[is currently sitting in the package-review queue](https://bugzilla.redhat.com/show_bug.cgi?id=1076192)</del><del> awaiting judgement</del>. **Update: 2014-03-27: **[python-bitmath is now in Fedora!](https://blog.lnx.cx/2014/03/27/python-bitmath-now-available-in-fedora/)

_However_, there are several other methods available for installation: installing from [PyPi](https://pypi.python.org/pypi/bitmath/), building your **own RPM**, and from **setup/distutils**.

https://gist.github.com/tbielawa/9590664


