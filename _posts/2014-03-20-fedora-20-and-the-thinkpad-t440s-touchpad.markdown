---
author: Tim Case
date: 2014-03-20 17:14:23+00:00
layout: post
title: Fedora 20 and the ThinkPad T440s touchpad
categories:
- Fedora
- GNU/Linux
- Planet
---

# Background


**UPDATE 2014-10-17 - **Installation of the "[Insensitive Message Tray](https://extensions.gnome.org/extension/616/insensitive-message-tray/)" extension has solved my issue with the notification bar frequently appearing when I did not want it to. This is on Gnome version 3.10.2. Note that pressing the **Super+M** keyboard shortcut will allow you to view the message tray when you want to.



My old work laptop, the ThinkPad T510, went out of warranty a few months ago. At work this means I'm eligible for a hardware refresh with [Best Monitors under 300](https://poweruphere.com/), i.e., a new  laptop. Because they're so much thinner and lighter, this time I decided to go with the 400 series. All in all it's a fine piece of hardware, so long as you're running Fedora 20 (or newer). I have two lingering issues however.



 	
  1. The default touchpad configuration

 	
  2. External display handling (which I won't go into at this time)


The T440s is one of those laptops trying it's hardest to emulate the Apple Trackpad. That is to say, the T440S has one giant touchpad, no left/right/middle buttons. Unfortunately for Linux users, this is usually either a hit or a miss. It was a miss for me.

My problems with laptop touchpads usually come down to a few basic things:

 	
  * Unintentional taps/clicks

 	
  * Random cursor movement due to palm/wrist bumping

 	
  * Random page/document scrolling


And specific to the T440s:

 	
  * Extremely difficult to click without dragging

 	
  * Difficult to find the right spot for middle clicking

 	
  * (Most interestingly) Randomly causing the Gnome notification panel to appear


In the past I've dealt with the former issues by simply disabling tap to click and touchpad scroll regions. But the T440s is an entirely different beast which required quite a bit more effort to make it usable.


# The Taming of the <del>Shrew</del> Touchpad


Here's how I was able to configure the ThinkPad T440s touchpad into something usable. I'll break it down point by point so you can pick and choose which options you wish to apply.

The first thing you need to know about is **synaptics**, the "touchpad input driver". This comes from the [**xorg-x11-drv-synaptics**](https://admin.fedoraproject.org/pkgdb/acls/name/xorg-x11-drv-synaptics) package. Synaptics ships a command called **synclient** which allows you to tune the touchpad behavior without restarting your X server. You should have this package already installed if you're running Fedora.


## Unintentional taps/clicks


This is simple. Just disable **Tap to click** in the **Mouse & Touchpad** settings panel.


## Random Movement


First, ensure that **Disable while typing** is checked in the **Mouse & Touchpad** settings panel.

If that is insufficient (as in my case) then you can set the synaptics **PalmDetect** option to **1**. This can be further tuned via the **PalmMinWidth** and **PalmMinZ** options, however, the defaults worked for me.


## Random Scrolling


Same as the **Random Movement** problem.


## Clicking without Dragging


This was the most frustrating issue with the T440s. The very act of **pressing down** on the touchpad to click causes the cursor to move. This makes it virtually impossible to click **anything** without your click target getting dragged around. We  can fix this with the **HorizHysteresis** and **VertHysteresis** options.



 	
  * ***Hysteresis** - The minimum horizontal/vertical HW distance required to generate motion events. **Default: 8**


The default hysteresis setting was insufficient for me. I changed both of mine to **30**.


## Middle Clicking


My specific issue here is that the middle-click region isn't wide enough by default. This caused many unintentional left or right clicks.

This was more challenging to figure out how to tune and required some Google-foo. Eventually I found myself on Peter Hutterer's "[Lenovo T440 touchpad button configuration](http://who-t.blogspot.com/2013/12/lenovo-t440-touchpad-button.html)" blog post. Peter's intention in that blog post is to emulate having buttons at the top and bottom edges of the touchpad, rather than the entire touchpad behaving as a clickable region. We can borrow his work though and apply it to this issue. In the blog post he sets another synaptics option, **SoftButtonAreas:**



 	
  * SoftButtonAreas="60% 0 0 0 40% 60% 0 0"




# Setting Synaptics Options


There are two methods available for setting synaptics options. The temporary solution is setting options via the **synclient** command (which I already referenced). The permanent solution is setting options via Xorg configuration files. Here's an example of using the **synclient** command to set the HorizHysteresis and VertHysteresis options:



 	
  * **synclient HorizHysteresis=30 VertHysteresis=30**


Here is my **01-synaptics.conf** file which sets all of these options permanently:

https://gist.github.com/tbielawa/9668968
