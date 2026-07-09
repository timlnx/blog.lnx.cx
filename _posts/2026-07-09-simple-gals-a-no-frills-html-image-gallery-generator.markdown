---
date: 2026-07-09
title: Simple Gals - A no-frills HTML image gallery generator
tags:
- Python
- project
- module
categories:
- Programming
- Photography
draft: false
author: Tim Case
layout: post
---


{{ "Simple Gals" | blog_anchor }}

This post announces "simple gals", or `simpleGals` stylized. This is my first
new semi-serious open source project in a long time. Like
[bitmath](https://bitmath.readthedocs.io/en/latest/) I had an itch I needed to
scratch. And that itch was the apparent lack of a modern day "simple HTML image
gallery generator".

*Back in my day*, on Mac the Photos application had this nifty feature. You
could export a gallery to a simple HTML bundle with forward/backward nagivation.
It looked a lot like they used the DocBook XSL stylesheets to generate a simple
thing that worked really well. Speaking of which, I still have an example of
thing I"m talking about.

{{ "The Grand Library" | blog_anchor }}

**The Grand Library** is one of the first big planned on graph-paper projects I
made in Minecraft, back when I was in college and it was still IN **ALPHA**
`v1.1.2_01`. According to the wiki, this screenshot must have been taken between
the ass-end of
[September](https://minecraft.wiki/w/Java_Edition_Alpha_v1.1.2_01) and [October
30th](https://minecraft.wiki/w/Java_Edition_Alpha_v1.2.0), 2010.


![That library is pretty sweet](https://lnx.cx/~tbielawa/Minecraft-GrandLibrary/Images/88.jpg)


You can see the rest of that gallery [here](https://lnx.cx/~tbielawa/Minecraft-GrandLibrary/) with (most of) the full build from beginning to end.

I think I had a screen recording, or screenshots of, a giant library burning
(after we backed up the world files). It brought the server (probably my old
macbook) to its knees. It was rough, buddy. But that's what we did back then: we
mined, crafted, and burned shit down/blew shit up. Not much has changed really.

{{ "Inspiration" | blog_anchor }}

That Apple generated HTML image gallery is the inspiration for simpleGals. It's
so stupid simple. Rows. Columns. Pagination. Click to view full size. It's
perfection.

![Old Gallery Screenshot](/assets/images/gallery-top.png)

But they took that away from us.

![Old Gallery Screenshot](/assets/images/gallery-bottom.png)

{{ "Modern Features (and anti-features)" | blog_anchor }}

simpleGals takes those core functions and extends them to work better in 2026.

simpleGals is trying to be a very simple command-line driven static HTML image
gallery generating tool. simpleGals just like to have fun, it doesn't want you
getting bogged down with all the tedious overhead associated with fancy gals,
running software that has to get patched, or paying another subscription.
simpleGals ain't like that.

simpleGals isn't for album management. You feed simpleGals directories of images
and in return you get some simple HTML files with thumbnails.

simpleGals inserts some simple javascript for quality of life enhancements. But
exactly 0 user-facing functionality requires javascript. The functionality
degrades gracefully to a simple point and click adventure, just like the old
days.

simpleGals has a full TUI interface for configuring projects and modifying
properties. The `sgui` tui can rebuild the gallery, just as well as the batch `simpleGals` command. There are progress bars, because I was feeling fancy.

Also, you get actual image-previews IN THE CONSOLE when you're setting
captions/alt text, or toggling individual "include in gallery" options.

![The gallery-wide settings panel in sgui](/assets/images/simplegals-sgiu-edit-gallery-properties.png "The sgui gallery settings screen: JPEG quality 95, 4 columns, 5 rows, a template field, and checkboxes for social media previews, camera EXIF, a gallery zip download, and the generated-with-simpleGals footer")

![Setting a photo's caption and alt text, with the image previewed right there in the terminal](/assets/images/simplegals-sgui-edit-single-picture.png "The sgui single-image editor for _LNX2037.JPG, showing caption and alt-text fields, an include-in-gallery checkbox, the original and thumbnail file sizes, and a small moon thumbnail rendered in the console")

![The sgui landing screen](/assets/images/simplegals-sgui-landing.png "The sgui landing screen with a list of JPG filenames down the left and a 'Select an image and press Enter' prompt on the right")

