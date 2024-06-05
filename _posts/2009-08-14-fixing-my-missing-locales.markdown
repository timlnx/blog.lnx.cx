---
author: tbielawa
comments: true
date: 2009-08-14 01:18:11+00:00
layout: post
link: https://blog.lnx.cx/2009/08/13/fixing-my-missing-locales/
slug: fixing-my-missing-locales
title: Fixing my missing locales
wordpress_id: 20
categories:
- GNU/Linux
- Planet
tags:
- Hardy
- Jaunty
- locale
- locales
- locales fix slicehost ubuntu
- slicehost
- ubuntu
---

**Background:** I run this server through [Slicehost](http://slicehost.com), and I enjoy their service immensely. When you set up your first server, or rebuild an existing server you get a very minimal GNU/Linux system installed. For obvious reasons, I like this a lot too.

**The problem:** Both the first time I built this server, and most recently when I rebuilt it to Jaunty Jackalope, the system locales weren't configured. I understand why this is done, that it happens doesn't bother me. That I had a hard time finding out how to properly set my locale frustrated me a little bit.

**How do you know** if your locales aren't correctly defined? On my Jaunty Jackalope system I see messages like this:


<blockquote>

>     
>     locale: Cannot set LC_MESSAGES to default locale: No such file or directory
>     locale: Cannot set LC_ALL to default
>     locale: No such file or directory
> 
> 
</blockquote>


I tried running **dpkg-reconfigure locales**, but that had no effect. Searching the Internet for the messages above provided a couple of possible solutions, but none of them looked like anything I was interested in. I'm a firm believer that if the Internet tells me to run a command with more than a couple of options, that it may work, but there is probably an easier, less cryptic solution. For example:


<blockquote>

>     
>     localedef -v -c -i en_US -f UTF-8 en_US.UTF-8
> 
> 
</blockquote>


No way I'm running that. I instead searched for "slicehost locale" and found this article: [Ubuntu Hardy setup](http://articles.slicehost.com/2008/4/25/ubuntu-hardy-setup-page-2). I enjoy this much more:

    
    locale-gen en_US.UTF-8
    
    update-locale LANG=en_US.UTF-8


Turns out that update-locale is a Debian/Ubuntu specific command. It updates your systems default locale setting file. I had checked for one before running it and found that none existed yet on my system. After running those two commands above I found one had been created with "LANG=en_US.UTF-8" in it. It's possible that running update-locale could have been all I needed to do to begin with.

I hope this helps some one else whose had this problem before or for the first time.



**Update: 2013-05-25: **This post has reached more parts of the Internet than I ever thought when I wrote it 4 years ago. Thanks to everyone who linked back instead of just copy and pasting the solution directly.

These days I'm running Fedora on [Linode](https://www.linode.com/). And all is well.
