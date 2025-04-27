---
author: Tim Case
date: 2013-04-04 22:38:29+00:00
layout: post
title: Using TTF fonts with DocBook and dblatex
categories:
- DocBook
- Documentation
- GNU/Linux
- Planet
- Publishing
- Tutorials
- XML
tags:
- adobe
- dblatex
- DocBook
- font
- latex
- otf
- pdf
- ttf
- xetex
- XML
---

# Update 2013-06-23:


Updating to the 0.3.4 version of dblatex has fixed many of the issues detailed in **The Aftermath** (end of this blog post). See [the blog post](http://blog.lnx.cx/2013/06/23/update-using-ttf-fonts-with-docbook-and-dblatex/) for more information.


# The Problem:


You're [writing a book](https://github.com/tbielawa/Virtual-Disk-Guide/) in [DocBook XML](http://www.docbook.org/tdg5/en/html/docbook.html), publishing it with [dblatex](http://dblatex.sourceforge.net/), and you dislike (or want to customize) the fonts it uses in the [rendered PDF](http://lnx.cx/docs/vdg/output/Virtual-Disk-Operations.pdf).

You hunt around the internet and find a nice [family](http://blogs.adobe.com/typblography/2012/09/source-code-pro.html) of [fonts](http://blogs.adobe.com/typblography/2012/08/source-sans-pro.html) you want to use in your final product. Best of all, they're free and released under the [Open Font License](http://en.wikipedia.org/wiki/SIL_Open_Font_License)!(Thanks, Adobe!)

The [dblatex documentation](http://dblatex.sourceforge.net/doc/manual/xetex.font.html) shows you how to set your fonts, but you can't seem to get it to work.



	
  * What do you put in for the names anyway?

	
  * Do spaces matter, or do you enter file names?

	
  * Where do you install the fonts?

	
  * OTF, TTF? What _type_ of font must they be?

	
  * Does the TeX engine even support this?




# The Solution:




## 1. Find The Family Names


_Caveat: I can verify that this solution works for **TTF** type fonts, I can not comment on how well it works for other font types._

First, you will need to identify the actual family name of the fonts you want to use. If your font is not installed on your system there is a command called **otfinfo** that can tell you the family of the font file (despite sounding specific to OTF fonts, this works on TTFs as well). The **otfinfo** command is provided by the **lcdf-typetools** package:

[gist id=5314443 bump=1]

If your desired font is _already_ installed on your system you can use the **fc-list** command instead to find the same information (**fc-list** is provided by the **fontconfig** package):

[gist id=5314447 bump=1]


## 2. Install New Font Files


If this is a new font on your system then you'll need to install it. There are (at least) two locations that work:



	
  * `$HOME/.fonts`

	
  * `/usr/share/fonts/truetype/`


The _Font Manager_ application (package: **font-manager**) also provides a graphical way to install font collections.


### (Optional) Rebuild Font Cache


Rebuild your font caches with the `**fc-cache -f -v**` command. If I recall correctly, you need to have super user permissions to run this. I may be wrong though.


## 3. Configure dblatex


The necessary changes to consume your custom fonts isn't difficult. Assume that up until now you've been rendering your PDFs from XML source like this:



	
  * `dblatex -o output/Virtual-Disk-Operations.pdf Virtual-Disk-Operations.xml`


We need to use XSLT stylesheets to define what our chosen font families are going to be. In this example I'm using **Source Sans Pro** for the body font and **Source Code Pro** for monospaced sequences.

First, make a directory called **xsl** and put a file like this in it:

[gist id=5314239 bump=1]

Next, slightly modify the command you run to build your PDFs (new parts are in **bold text**):



	
  * ` dblatex **-p xsl/dblatex-pdf.xsl -b xetex** -o output/Virtual-Disk-Operations.pdf Virtual-Disk-Operations.xml`


**-p xsl/dblatex-pdf.xsl**: This tells dblatex that we're providing a "user stylesheet" to use when transforming the XML. This stylesheet only has our font customizations in it, but you can put much [more in them](https://github.com/tbielawa/Virtual-Disk-Guide/blob/master/xsl/dblatex-pdf.xsl) than just that.

**-b xetex**: This tells dblatex that instead of rendering our PDF with **pdftex** we want to use a different backend driver (or "TeX engine"). Specifically we want to use the **xetex** driver. We choose the xetex driver because of it's [superior font handling](http://wiki.contextgarden.net/Fonts_in_XeTeX) abilities via the [**fontspec** LaTeX package](http://www.ctan.org/tex-archive/macros/xetex/latex/fontspec/). When we use the xetex engine dblatex will insert some special macros into the intermediate LaTeX document it generates, this process is transparent to the end user:

[gist id=5314759 bump=1]

After this, dblatex runs any custom post-compilation scripts, and then hands the intermediate file off to xetex where it is finally transformed into PDF format.


# 4. The Aftermath


In my case there were some unexpected side-effects from switching backends. Here's what I've noticed so far:



	
  * [remark elements](http://www.docbook.org/tdg5/en/html/remark.html) no longer appear in PDF output

	
  * The DRAFT watermark no longer appears

	
  * [screen elements](http://www.docbook.org/tdg5/en/html/screen.html) no longer show a 'wrapping character' in long lines


[caption id="attachment_425" align="aligncenter" width="300"][![Compare new formatting with old](https://blog.lnx.cx/wp-content/uploads/2013/10/new-old-300x236.png)](https://blog.lnx.cx/wp-content/uploads/2013/10/new-old.png) On the left is the book rendered with xetex and the new fonts. On the right is the book rendered with pdftex and no special font customizations.[/caption]

The only thing that really bothers me is the broken word-wrapping character. I can deal with the others breaking. I had intended to remove them from the final product anyway.
