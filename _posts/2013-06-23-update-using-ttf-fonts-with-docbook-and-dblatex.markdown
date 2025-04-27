---
author: Tim Case
date: 2013-06-23 18:46:17+00:00
layout: post
title: 'Update: Using TTF Fonts with DocBook and Dblatex'
categories:
- DocBook
- Documentation
- GNU/Linux
- Planet
- XML
---

_This is an update to [a previous blog post](http://blog.lnx.cx/2013/04/04/using-ttf-fonts-with-docbook-and-dblatex/) where I described how I was able to use custom fonts in my **docbook -> dblatex -> pdf** toolchain by switching to the **XeTeX** backend._

I closed that blog post with a few caveats:



	
  * [remark elements](http://www.docbook.org/tdg5/en/html/remark.html) no longer appear in PDF output

	
  * The DRAFT watermark no longer appears

	
  * [screen elements](http://www.docbook.org/tdg5/en/html/screen.html) no longer show a ‘wrapping character’ in long lines


I'm pleased to say that I've recently revisited my publishing toolchain and two of those three caveats are no longer an issue.

Through a series of unexpected clicks on the [dblatex releases page](http://dblatex.sourceforge.net/releases/download.html) I found myself looking at links to download newer versions of dblatex than I was presently using. Though the updates are not scheduled for inclusion in Fedora 17, they are (going to be) available in [Fedora 18](https://admin.fedoraproject.org/updates/FEDORA-2013-9636/dblatex-0.3.4-6.fc18) and [Fedora 19](https://admin.fedoraproject.org/updates/FEDORA-2013-9567/dblatex-0.3.4-6.fc19). I quickly skimmed over the changelogs and found some interesting bug fixes. Such as:

**[dblatex 0.3.3](http://sourceforge.net/projects/dblatex/files/dblatex/dblatex-0.3.3/):**



	
  * Remove hard-coded paper size and add some parameters for page layout setup:

	
    * Parameters to define page sizes and margins.

	
    * Parameters to have crop marks for pre-press PDF output.




	
  * Fix [Debian bug #629514](http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=629514) to have draft watermark with XeTeX backend.


Because I'm targeting smaller book dimensions for the [Virtual Disk Guide](http://lnx.cx/docs/vdg/output/Virtual-Disk-Operations.pdf) I was most interested in the first fix mentioned: the removal of hard-coded paper sizes. Unfortunately, the documentation on the official dblatex site has not been updated in quite some time. It seems that they're still displaying an early 0.3.x release of the docs.

Wouldn't you know it... Some kind souls out there on the Internets have actually built and host [the most recent version of the dblatex documentation](http://fossies.org/linux/privat/dblatex-0.3.4.tar.gz:a/dblatex-0.3.4/docs/xhtml/manual/index.html) online! Now I'm able to get a smaller page format which is suitable for the dimension options on lulu.com without having to [directly hack any of the dblatex styles](http://janixsoft.wordpress.com/2013/02/15/dblatex/). All it takes now is: **<xsl:param name="paper.type">a5paper</xsl:param>** Header and footer content receive appropriate margins automatically, too. No more fussing around!


# Other notes





	
  * The draft watermark works in PDF output once again.

	
  * Hyphenation in examples works correctly again.


