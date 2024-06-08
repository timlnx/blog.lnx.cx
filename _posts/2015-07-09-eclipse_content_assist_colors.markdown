---
author: al
date: 2015-07-09 21:27:24+00:00
layout: post
title: Eclipse Content Assist Colors
categories:
- Fedora
- Programming
tags:
- css
- eclipse
- fedora 22
- gtk3
---

When I write Java, I use Eclipse.  It does what I need it to do, but there are a few things about it that bother me.  One of them is that Eclipse allows very limited control over the color scheme.  Most of the color settings are inherited from the desktop theme that you're using.  I recently upgraded to Fedora 22 and with the Adwaita theme under XFCE, this is what the Eclipse content assist dropdown looks like:

[caption id="attachment_766" align="alignnone" width="688"][![Can you read the top selection?](https://blog.lnx.cx/wp-content/uploads/2015/07/Tooltip_001.png)](https://blog.lnx.cx/wp-content/uploads/2015/07/Tooltip_001.png) Can you read the top selection?[/caption]

Notice how close the foreground and background colors are for the selected item.  I find that intolerable.  I'm not sure exactly why Eclipse is picking that color combination, because the content assist object is a GtkTreeView which has the selected item background color set to cerulean blue in Adwaita.  In any case, to fix it create `~/.config/gtk-3.0/gtk.css` with the following contents:

    
    <code>
    GtkTreeView:selected {
        background-color: @theme_selected_bg_color;
    }
    </code>


That snippet will override whatever weirdness is going on with the content assist dropdown and set the background color back to the theme's default background color for selected items. You can also just set it to a hex value. Note that this setting will apply **to any GTK3 application**, but that should be all right since you're just asking the theme to do what it is already doing.
