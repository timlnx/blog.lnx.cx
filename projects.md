---
layout: page
title: Projects
permalink: /projects/
description: >-
  Things I build elsewhere: famoe.ly, a jam band fansite with a song catalog,
  setlist prediction, and more data visualization than strictly necessary.
seo:
  type: WebPage
---

I do things in other places, too. Check 'em out.

# famoe.ly

*jam band fansite w/ song catalog and lots of data visualization*

In 2026 I bought the [famoe.ly](https://famoe.ly/) domain so I could
host a fan site for [moe.](https://www.moe.org/) with some
stats/data/math tools I am working on. It's expanded to include a few
additional tools I built along the way to validate the set lists and
track length data I was normalizing and processing.

* [The Songbook](https://famoe.ly/songbook/) - Adjustable "what were
  they playing and when" song catalog with data going back to 2020.
* [The Scorecard](https://famoe.ly/scorecard/) - I'm trying to predict
  upcoming sets based on years of historical data. It gets more
  accurate the closer we get to an upcoming show. I started it to
  build practice setlists for me to get familiar with their recent
  catalog. Now it's just fun.
* [The Tape Measure](https://famoe.ly/tapemeasure/) - Normalizing and
  validating data. Lots of visuals about average song lengths and
  relationships with other songs: common segues, frequent
  opener/closer status, sandwdichth plays (wrapping a song around
  another full song). I just think it's neat!

![They're Neat](/assets/images/neat.png "Marge Simpson holding a potato saying that she just thinks they're neat")

famoe.ly wouldn't be possible without the
[Internet Archive](https://help.archive.org/help/how-do-i-donate-to-the-internet-archive/)
for hosting all of the source data, and the famoe.ly fandom for their
decades of uploaded live recordings.

# Python - bitmath

bitmath is a Python library for using file size units (GiB's, kB's, etc) as
objects in code just like numbers.

* [Source - Github](https://github.com/timlnx/bitmath)
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
[string.format](https://docs.python.org/3/library/string.html).




# The Virtual Disk Guide

I wrote a book! It's free.

* [Read it Online](http://scribesguides.com/)
* [GitHub: Book Source](https://github.com/timlnx/Virtual-Disk-Guide)

*The Linux Sysadmin's Guide to Virtual Disks* demonstrates the core concepts of virtual disk management. Real-world problems are covered in the book's "Cookbook" section. Other topics include: helper utilities, disk formats, troubleshooting tips, performance considerations, and comprehensive appendices.
