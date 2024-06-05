---
author: al
comments: true
date: 2015-09-18 14:00:12+00:00
layout: post
link: https://blog.lnx.cx/2015/09/18/eclipse-darkness/
slug: eclipse-darkness
title: Eclipse Darkness
wordpress_id: 803
categories:
- Fedora
tags:
- eclipse
- fedora 22
- java
---


I've made several posts previously about the difficulties I've had with Eclipse and Gnome's Adwaita theme: menu elements that have too little contrast to read, poor color choices, etc.  I even took a stab at creating [my own GTK3 theme](https://github.com/awood/eclipse-graphene) to deal with the problem.






I'm happy to report that my efforts are now obsolete.  Eclipse Mars (now available in Fedora 22) has made significant improvements to the Dark theme (set under Preferences -> General -> Appearance).  However, if you're using Adwaita, the top menu bar is gray text on grey background.  The simple fix is to change to the Adwaita Dark theme just for Eclipse.  Here's how:







  1. Open `/usr/share/applications/eclipse.desktop` in your text editor of choice.


  2. Modify the `Exec` line to read

    
    <code>
    Exec=env GTK_THEME=Adwaita:dark eclipse
    </code>





  3. Done!





The one gotcha is that when you update the eclipse-platform package, it will destroy the changes you've made in the desktop file so you'll have to redo them.  But that's a small price to pay in my opinion.



[caption id="attachment_804" align="alignnone" width="1154"][![Screenshot of Eclipse Mars with Dark theme and Adwaita Dark GTK theme](https://blog.lnx.cx/wp-content/uploads/2015/09/eclipse_adwaita_dark.png)](https://blog.lnx.cx/wp-content/uploads/2015/09/eclipse_adwaita_dark.png) Eclipse Mars with the Adwaita Dark GTK theme.[/caption]
