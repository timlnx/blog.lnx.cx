---
date: 2026-07-24
title: I am (not) tracking you
tags:
- blog
- security
- privacy
- eff
- privacy badger
- apache
- httpd
- do not track
categories:
- Planet
- Fedora
- GNU/Linux
- Privacy
draft: false
author: Tim Case
layout: post
description: >-
  Wherein I explain how the new "tracker" works on this site while respecting your privacy
---

If you look at the bottom of the site now you'll see I have published
a [privacy](/privacy) document. Normally I expect updates like this to
explain how somebody is actively trying to track me harder. This is
actually the opposite of that and I hope it can be useful to other
folks who want to get better signal to noise ratio with still
respecting their readers privacy wishes.

{{ "How does it work?" | blog_anchor2 }}

It's simple. A tiny bit of unessential javascript loads on each page
load. The javascript checks about 4 different ways to see if you are
asking not to be tracked:

{% raw %}
```javascript
(function () {
  // If you have asked not to be tracked, stop here. Fire nothing.
  var dnt = navigator.doNotTrack || window.doNotTrack || navigator.msDoNotTrack;
  if (dnt === "1" || dnt === "yes" || navigator.globalPrivacyControl) { return; }
```
{% endraw %}

If that's your wish, it skips. If you leave that open, then it loads a
small invisible svg:

{% raw %}
```javascript
  new Image().src = "/assets/turnstile.svg?" + Date.now();
})();
```
{% endraw %}

The [privacy](/privacy) page explains in much greater detail how all
of this works.

{{ "Web Server Logs?" | blog_anchor2 }}

You won't appear in those either.

Requests for turnstile.svg are sent to a different log file, and
that's **only if** apache does not detect the do not track header from
your browser.

If that isn't set then an item is logged in the turnstile log. For
example:

`2026-07-24 "https://blog.lnx.cx/privacy/"`

That's it. It says on that day, July 24th, a request was made from (in
this example) the [privacy](/privacy) page. No time component, only a
date stamp. No IP address. Just a date and a referral page. I can't
use this to line up anything with the other logs to build a profile. I
don't want to.

