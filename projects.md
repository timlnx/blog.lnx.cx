---
layout: page
title: Projects
permalink: /projects/
---

I do things in other places, too. Check 'em out.

# Python - bitmath

bitmath is a Python library for using file size units (GiB's, kB's, etc) as
objects in code just like numbers.

* [Source - Github](https://github.com/tbielawa/bitmath)
* [Docs - Read the Docs](https://bitmath.readthedocs.io/en/latest/)

If you do a lot of file size math, bitmath could save you quite a bit of time.

* Converting between **SI** and **NIST** prefix units (``kB`` to ``GiB``)
* Converting between units of the same type (SI to SI, or NIST to NIST)
* Automatic human-readable prefix selection
* Basic arithmetic operations (subtracting 42KiB from 50GiB)
* Rich comparison operations (`1024 Bytes == 1KiB`)
* bitwise operations (`<<`, `>>`, `&`, `|`, `^`)
* Reading a device's storage capacity (Linux/OS X support only)
* `argparse` integration as a custom type
* `click` integration as a custom parameter type
* `progressbar` integration as a better file transfer speed widget
* String parsing
* Sorting


In addition to the conversion and math operations, `bitmath` provides human
readable representations of values which are suitable for use in interactive
shells as well as larger scripts and applications. The format produced for these
representations is customizable via the functionality included in stdlibs
[string.format](https://docs.python.org/2/library/string.html).

# The Virtual Disk Guide

I wrote a book! It's free.

* [Read it Online](http://scribesguides.com/)
* [GitHub: Book Source](https://github.com/tbielawa/Virtual-Disk-Guide)

*The Linux Sysadmin's Guide to Virtual Disks* demonstrates the core concepts of virtual disk management. Real-world problems are covered in the book's "Cookbook" section. Other topics include: helper utilities, disk formats, troubleshooting tips, performance considerations, and comprehensive appendices.
