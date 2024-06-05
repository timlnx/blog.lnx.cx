---
author: al
comments: true
date: 2015-05-15 14:09:43+00:00
layout: post
link: https://blog.lnx.cx/2015/05/15/getting-consistent-fingerprints-from-git-archive/
slug: getting-consistent-fingerprints-from-git-archive
title: Getting consistent fingerprints from git-archive
wordpress_id: 732
categories:
- /dev/null
---

The "git archive" man page states:


<blockquote>
git archive behaves differently when given a tree ID versus when given a commit ID or tag ID. In the first case the current time is used as the modification time of each file in the archive.
</blockquote>


By using the current time in this case, git-archive is dooming all of our tarballs to have constantly changing SHA256 hashes.  A lot of build systems, including Fedora's Koji, rely on source tarballs maintaining a consistent fingerprint.  What is a person to do?






Fix it of course!  Below is a Python 2 program I wrote that addresses the issue.  The code is well-commented (I hope) so you should be able to follow along.  You give it the Unix timestamp you want the files to have, the git ref you want baked into the tar header, and the initial tarball.  The result is printed to stdout so just redirect that to wherever you please (or pipe it into gzip).  It also has some code in there to deal with tarballs created by the maven-assembly plugin, but it doesn't surface that on the primitive CLI.  I'm leaving that as an exercise for the reader I guess.




https://gist.github.com/awood/9ed77d46abe707be451c
