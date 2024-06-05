---
author: al
comments: true
date: 2015-03-16 14:55:27+00:00
layout: post
link: https://blog.lnx.cx/2015/03/16/open-url-bug-with-xdg-on-xfce4/
slug: open-url-bug-with-xdg-on-xfce4
title: Open URL Bug with XDG on XFCE4
wordpress_id: 722
categories:
- /dev/null
---

Recently I noticed that in my IRC client, when I right-click a URL and select "Open Link In Browser", the system would open a new browser window (or tab if appropriate) but not pointed to the link I wanted to visit.  It would just open the home page.





What gives?  Well, I happen to know from experience that in Linux most programs that need to use a "default" type service of which there are many implementations (such as a web-browser) use the `xdg-open` command.  XDG associates different mime-types to default applications.  Step one then is to figure out what's going on with XDG.

    
    <code>
    % xdg-mime query default text/html
    firefox.desktop firefox.desktop
    </code>


Here I'm asking XDG what applications are associated with the `text/html` mime-type.  Seeing two firefox.desktop files was a bit of a surprise.  Let's find out more!

    
    <code>
    % locate firefox.desktop
    /usr/share/applications/firefox.desktop
    /usr/share/xfce4/helpers/firefox.desktop
    </code>


So I open up those two files and the first file looks normal and that file actually belongs to the Firefox package according to `rpm -qf`.  In the second file, I see

    
    <code>
    X-XFCE-Commands=%B -remote "openURL(about:blank,new-window)";%B;
    X-XFCE-CommandsWithParameter=%B -remote "openURL(%s,new-window)";%B "%s";
    </code>


That looks strange to me.  If I want to open a URL from the command line, I don't use `openURL`.  Let's see what happens if I replace that with

    
    <code>
    X-XFCE-Commands=%B;
    X-XFCE-CommandsWithParameter=%B "%s";
    </code>


Aha!  It works!  But why?  Well, after a little searching I came across [Mozilla Bug 1080319](https://bugzilla.mozilla.org/show_bug.cgi?id=1080319).  Looks like the `openURL` was a legacy thing and got removed in Firefox 36.  And a quick `rpm -q firefox` confirms that I'm running that version.  Firefox 36.0.1 add support for `openURL` back in, but my hack will serve until that version hits Fedora.

