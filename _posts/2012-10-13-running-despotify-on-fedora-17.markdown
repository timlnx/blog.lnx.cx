---
author: Tim Bielawa
date: 2012-10-13 01:40:45+00:00
layout: post
title: Running despotify on Fedora 17 x64
categories:
- GNU/Linux
- Planet
- Tutorials
tags:
- 64 bit
- despotify
- fedora 17
- Linux
- spotify
---

[Spotify](http://www.spotify.com) is pretty damn cool. I think we can all agree on this. What's even cooler (if you're an Open Source/Linux geek) is running a third-party ncurses client to connect to Spotify. Here's what I had to do on Fedora 17 (64 bit).



	
  1. Install the necessary packages to checkout and build the application

	
    1. Per the [Open Grieves](http://blog.hacka.net/#post12) instructions, install the following packages: `subversion libtool libogg-devel libvorbis-devel pulseaudio-libs pulseaudio-libs-devel zlib-devel gstreamer-devel libao-devel openssl-devel ncurses-devel`




	
  2. Checkout the **despotify **source code from SVN

	
    1. `svn co https://despotify.svn.sourceforge.net/svnroot/despotify despotify`




	
  3. Move into the `despotify/src`directory

	
    1. `cd despotify/src`




	
  4. Build and install the application

	
    1. `make`

	
    2. `sudo make install`




	
  5. Because we're specifically talking about an **x64** installation we need to fix how `libdespotify.so.0` got installed. Now, I'm sure there's a more intelligent way to do this (please tell me if you know by commenting on this blog post, or hit me up on twitter: [**@tbielawa**](https://twitter.com/tbielawa)), but lacking the necessary knowledge, I opted use symbolic links (note: this fixes the "`despotify: error while loading shared libraries: libdespotify.so.0:" cannot open`error message you may be seeing)

	
    1. `cd /usr/lib64`

	
    2. `sudo ln -s ../lib/libdespotify.so.0`




	
  6. Run the application (**protip:** Press the "`?`" key to see a list of shortcuts. `ctrl+e` is a shortcut for `:connect`)

	
    1. `despotify`




	
  7. If you try and log in now you're most likely going to receive a "`User not found`" error message. Per the information in [this thread on the archlinux forums](https://aur.archlinux.org/packages.php?ID=25039)I did the following:

	
    1. Logged into the [**Spotify web interface**](http://www.spotify.com)

	
    2. Went into the "**Edit Profile**" page

	
    3. Went to the "**Set a password for your devices**" page

	
    4. This page will give you a number you will use as your **despotify** user name, save it somewhere for the next step. Click the link/button to receive an email which allows you to set the password for this account

	
    5. Read said email, click link in email, set "device" account password




	
  8. Now, using the account credentials created in the last step, you can log into the **despotify** application


That's everything I had to do. So, is it worth it? No. Not really. But it was a fun little experiment/challenge.

The interface is immature, _at best_. It's lacking most/all of the functionality I really enjoy in the official Spotify client, such as creating and listening to artist/song based radios, receiving/sending music suggestions to friends, Starring songs for offline listening later, etc...

What you **can do** is search for artists/tracks and play the results, and, impress your friends? I guess. (probably not though)
