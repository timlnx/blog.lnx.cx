---
author: al
comments: true
date: 2014-11-13 22:32:30+00:00
layout: post
link: https://blog.lnx.cx/2014/11/13/inspecting-spec-files/
slug: inspecting-spec-files
title: Inspecting Spec Files
wordpress_id: 663
categories:
- Fedora
tags:
- packaging
- rpm
---

In my experience, the best way to learn about how to package RPMs is to look at how other people package RPMs.  That means looking at lots of spec files.  Sure `fedpkg` will let you clone lots of package repos, but what if you only have the SRPM?  You can get the spec file out of a SRPM, but it takes a little work with `cpio`, a tool with so many options that I can never remember the exact invocation.  So I wrote a quick two-liner to save me some aggravation:

    
    <code class="prettyprint">#! /bin/sh
    spec=$(rpm -qlp $1 | grep -E '\.spec$')
    rpm2cpio $1 | cpio -i --to-stdout $spec</code>



And how can you get the SRPM?  Simple, install `yum-utils` then run

    
    <code class="prettyprint">$ yumdownloader --source --downloadonly PACKAGE_NAME</code>
