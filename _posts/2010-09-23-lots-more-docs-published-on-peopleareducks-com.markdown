---
author: Tim Bielawa
date: 2010-09-23 00:38:09+00:00
layout: post
title: Lots more docs published on PeopleAreDucks.com
categories:
- DocBook
- Documentation
- Emacs
- GNU/Linux
- OS X
- Planet
- Tutorials
- XML
---

While I've been gone from the blogging world I've still been working on projects. Mostly I've been working on documentation.




	
  * [Debian/Fedora Package Management](http://wiki.peopleareducks.com/FedoraPackageManagement) comparison. Since switching my [Slice](https://manage.slicehost.com/customers/new?referrer=8f0b1ecda01d4deda9c14f470d8d6c3b) to Fedora from Ubuntu I've picked up plenty of commands for managing packages. This is just a quick wiki page giving the roughly equivalent commands from Debian/Ubuntu to Fedora/RedHat.

	
  * [regexp basics](http://peopleareducks.com/docs/regexp-basics/output/) is a brief tutorial on regular expressions. My roommate [abutcher](http://afrolegs.com) put it together for his WVU CS210 (Advanced File and Data Structures) course. The [DocBook 5](http://www.docbook.org) sources are available [in git](http://git.peopleareducks.com/docs/regexp-basics.git).

	
  * The biggest doc project I've been working on again (finally) is my Virtual Disk Guide aimed at power users and sysadmins. Currently it's a **rough** draft and is constantly undergoing major changes and additions. It's available as a [single HTML document](http://peopleareducks.com/docs/vdg/output/Virtual-Disk-Operations.html), [chunked into multiple pages](http://peopleareducks.com/docs/vdg/html/), and in [PDF format](http://peopleareducks.com/docs/vdg/output/Virtual-Disk-Operations.pdf). You can get the [DocBook 5](http://www.docbook.org) formatted source to it through [my GitHub](http://github.com/tbielawa/Virtual-Disk-Guide) account.



[My Project Templates project](http://github.com/tbielawa/Project-Templates) has seen some much needed attention recently. The [DocBook starter project](http://github.com/tbielawa/Project-Templates/tree/master/DocBook/) has been completely redone. Here's some reasons you might want to use it.



	
  * Includes a [basic starter document](http://github.com/tbielawa/Project-Templates/blob/master/DocBook/index.xml) with most of the available informational tags present but commented out so all you need to do is uncomment the elements you need for your document.

	
  * Inclues a customizable [Makefile](http://github.com/tbielawa/Project-Templates/blob/master/DocBook/Makefile) that can adapt itself to different operating systems (Debian/Ubuntu, Fedora/RedHat, and Mac OS X) by just uncommenting the proper directory paths for the schema and stylesheet files.

	
  * The Makefile has targets for: cleaning up, creating [schema locator files](http://github.com/tbielawa/Project-Templates/blob/master/DocBook/.schemas.xml) for [nxml-mode](http://www.thaiopensource.com/nxml-mode/) in emacs, publishing PDFs, and publishing chunked or single HTML documents.

	
  * The comments in the Makefile also tell you what packages you need to install to get the schema and stylesheet files.



Using the Makefile for publishing only requires having xsltproc and dblatex installed. Both of which are available through your favorite package manager.
