---
author: cvenghaus
comments: true
date: 2009-09-10 15:26:55+00:00
layout: post
link: https://blog.lnx.cx/2009/09/10/rsync-on-cygwin/
published: false
slug: rsync-on-cygwin
title: RSYNC on Cygwin
wordpress_id: 86
categories:
- GNU/Linux
tags:
- Cygwin
- IIS
- RSYNC
- SSH
- Windows
---

We currently use a proprietary CMS for our public web sites.  The current version of the CMS we use allows you to publish content via "User-Defined Jobs."  These can be scripts processed by the CMS system, executables, or URL's.  We currently use the URL method to execute an ASP script that executes a batch file that runs RSYNC.  This allows publication to be be manually run by a normal user in the event that CMS publication is not available.

We're in the process of setting up a new web server to replace our old one.  The old one has been having software and hardware issues since before I started working here, and we've been jonesing to get it updated.

The new machine is running IIS7 on Windows Server 2008.  In order for RSYNC to work, I needed to install Cygwin.

Need to finish this later... :(
