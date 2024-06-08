---
author: al
date: 2015-03-02 16:30:50+00:00
layout: post
title: Custom mappings for the Logitech R400 under Fedora 20
categories:
- Fedora
- GNU/Linux
- Tutorials
- Xorg
tags:
- logitech
- presentation
- r400
- scancodes
- udev
---

I wanted to use a [Logitech R400](http://www.logitech.com/en-us/product/wireless-presenter-r400) that a friend loaned my in a presentation, but I wanted to tweak the mappings for the buttons a bit. My presentation is done using [Reveal.js](http://lab.hakim.se/reveal-js/#/) and uses both left/right and up/down. The R400 has four buttons but two of them are mapped to "go to black screen" and "slideshow mode" neither of which is useful to me. Here is how I fixed it in Fedora 20.



	
  1. Create the directory `/etc/udev/hwdb.d`

	
  2. Write the following out to `/etc/udev/hwdb.d/99-logitech-r400.hwdb`

    
    <code>
    # The lower left button actually emits two
    # different scancodes depending on the state of
    # the "presentation".
    # E.g. one code to start and one to stop.
    keyboard:usb:v046DpC538
      KEYBOARD_KEY_70029=up
      KEYBOARD_KEY_7003E=up
      KEYBOARD_KEY_70037=down
      KEYBOARD_KEY_7004B=left
      KEYBOARD_KEY_7004E=right   
    </code>


This maps the left and right buttons to left and right, the both states of the slideshow button to up, and the blank screen button to down. The `046D` is the Logitech vendor code and the `C538` is the model number. Those magic numbers after "KEYBOARD_KEY" are the scancodes associated with the button. Supposedly `showkey --scancodes` will display them but I couldn't get that to work and ended up taking them from [another blog post](http://derickrethans.nl/logitech-r400.html).

	
  3. Now we need to load this information.

    
    <code>
    # udevadm hwdb --update && udevadm trigger
       </code>




	
  4. We can test by running the command below and pushing the buttons

    
    <code>
    # xev | grep -A2 --line-buffered '^KeyRelease' | sed -n '/keycode /s/^.*keycode \([0-9]*\).* (.*, \(.*\)).*$/\1 \2/p'
    </code>




	
  5. Everything should work now, but if we unplug the USB receiver everything gets reset. That's annoying so we will fix it

	
  6. Write the following to `/etc/udev/rules.d/99-logitech-r400.rules`

    
    <code>
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c538", IMPORT{builtin}="hwdb 'keyboard:usb:v046DpC538'", RUN{builtin}+="keyboard"
    </code>


That will import our custom mapping when the USB receiver is plugged in.


Thanks to the following who helped me figure all this out:

	
  * [Tweaking the Logitech R400 presenter tool on Linux by Derrick Rethams](http://derickrethans.nl/logitech-r400.html)

	
  * [udevadm](http://www.freedesktop.org/software/systemd/man/udevadm.html)

	
  * [Udev - Crashcourse Wiki](http://www.crashcourse.ca/wiki/index.php/Udev#.22Testing.22_a_udev_rule)

	
  * [How to create custom keymaps now that libudevkeymap is gone](https://ask.fedoraproject.org/en/question/37598/)

	
  * [Writing Udev Rules by Daniel Drake](http://www.reactivated.net/writing_udev_rules.html)


