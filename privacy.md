---
layout: page
title: Privacy
permalink: /privacy/
description: >-
  What this site records, why, and how it respects Do Not Track. No cookies,
  profiling, or third parties. It's just a turnstile.
seo:
  type: WebPage
---

I run this blog myself, on a small server I rent. I wanted to know one thing:
roughly how many **real people** read a post, versus how many automated scrapers
hammer it. Lately the scrapers badly outnumber and outshout the humans in my
logs, and I could not tell the two apart. What follows is the least-invasive
thing I could build that answers "human, or bot?" without watching you.

I care about this stuff. I donate to the [Electronic Frontier
Foundation](https://www.eff.org/) every year and I browse with
[Privacy Badger](https://privacybadger.org/) and uBlock Origin like a lot of
you do. So this is built to the standard I would want applied to me. None of
what follows is a boast, it's just me showing receipts.

{{ "The short version" | blog_anchor2 }}

When a page renders in a real browser, that browser quietly loads a single
1x1 image, `/assets/turnstile.svg`. My web server writes one ordinary log
line for that request. Counting those lines tells me "a real browser rendered
a page." That is the whole idea. It is a **turnstile**: it clicks once when
someone walks through, and it cannot know who walked through.

{{ "What it does not do" | blog_anchor2 }}

- **No cookies.** None are set, none are read. Check for yourself.
- **No identifier in the count.** The turnstile writes to its own log that
  records only a date and which page - no IP address, no time of day, no name.
  There is nothing in it to tie one visit to another, or to you.
- **No third parties.** The image comes from this site. Nothing is sent to
  Google, to Meta, or to an analytics company.
- **No JavaScript needed to read the blog.** The site is fully usable with JS
  switched off. The one script here does nothing to the page.

{{ "What about my IP address?" | blog_anchor2 }}

Fair question. Two answers:

The **turnstile count does not keep it.** Those hits go to their own log that
records only the date and the page. **No IP** and **no clock time**. A counting
line cannot be matched back to anything else in the daily flood of bot traffic.
That separation is the whole point of a second, deliberately thin log.

The **rest of the web server does log your IP**, on every page and image
request, the same as every web server there is. I need it to keep the site up
and to block abuse. A banned scanner is just a banned IP. I do not use it to
profile you, I never share it or sell it, and it ages out when the logs rotate.

Two levers here, and they are not the same, so let me be exact. **Do Not Track
and GPC turn off the turnstile count**. That is the whole of what they do on
this site. They do **not** switch off the normal server log, which records IPs
for security no matter what you send; something that might be an attack gets
logged like anything else. If what you want is for me not to see your real IP at
all, that is what a **VPN** is for. If you use a VPN then the address in my log
is the exit node's, not yours.

{{ "It respects Do Not Track and Global Privacy Control" | blog_anchor2 }}

The single script on this site checks for a **Do Not Track** or **Global Privacy
Control** signal *before* it does anything. If you send either one, the
turnstile **never fires**. I.e., no request leaves your browser, so there is
nothing to log and nothing to count. As a backup, my server is also set up to
discard the request if it ever arrives carrying those signals. Either way: you
asked not to be counted, and you are not.

If you run **Privacy Badger**, **uBlock Origin**, or you browse with JavaScript
off, the turnstile also never fires. You are just as welcome here, and you read
exactly the same site as everyone else. You simply are not counted. That means
my count is always an **undercount**, never an inflated one. I am glad to make
that trade: I would rather miss you than track you.

{{ "The entire mechanism, shown" | blog_anchor2 }}

You should be able to check my claims instead of trusting them, so here is the
whole thing:

Here is exactly what the script (the only JavaScript on this site) does:

{% raw %}
```javascript
(function () {
  // If you have asked not to be tracked, stop here. Fire nothing.
  var dnt = navigator.doNotTrack || window.doNotTrack || navigator.msDoNotTrack;
  if (dnt === "1" || dnt === "yes" || navigator.globalPrivacyControl) { return; }

  // Otherwise, load one 1x1 image. The "?" + timestamp only defeats caching so
  // each page view counts once; it is the clock, not an identifier.
  new Image().src = "/assets/turnstile.svg?" + Date.now();
})();
```
{% endraw %}

The image it loads, `/assets/turnstile.svg`, is itself just a comment
explaining what it is:

{% raw %}
```xml
<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1">
  <!-- turnstile.svg - a privacy-respecting visit counter. No cookie,
       no identifier, no profile. It clicks once when a real browser
       renders a page, and cannot know who. -->
</svg>
```
{% endraw %}

Then my server decides what to do with that request. These are the actual Apache
directives that handle it. Here's the whole server side, nothing held back:

{% raw %}
```apache
# The turnstile log format: a date with no clock time, and which page the
# beacon came from. No %h (your IP), and no %r, so even the "?" cache-buster,
# which carries a millisecond timestamp, is never written down. Two fields.
LogFormat "%{%Y-%m-%d}t \"%{Referer}i\"" turnstile

# ...and inside the blog's virtual host, three lines decide its fate:

# 1. Keep the beacon out of the normal access log, so no IP is kept for it.
SetEnvIf Request_URI "^/assets/turnstile\.svg" is_turnstile

# 2. Count it ONLY when you have not sent Do Not Track or Global Privacy Control.
SetEnvIfExpr "%{REQUEST_URI} =~ m#^/assets/turnstile\.svg# && ! ( %{HTTP:DNT} == '1' || %{HTTP:Sec-GPC} == '1' )" turnstile_count

# 3. Everything-but-the-beacon goes to the usual log; the beacon, date and page
#    only, goes to its own file. A Do-Not-Track beacon matches neither line and
#    is written nowhere at all.
CustomLog logs/blog.lnx.cx_access_log    stats     env=!is_turnstile
CustomLog logs/blog.lnx.cx_turnstile_log turnstile env=turnstile_count
```
{% endraw %}

And the turnstile's log line is deliberately thin. It is written to its own
file, apart from the normal server logs, and holds only two things: the date
(not the time of day) and which page fired it. No IP address, no clock, no name.
A day of them adds up to "this post was rendered 14 times on the 24th" and
nothing more. There's no practical way to tie it back to a person or IP address.

That is the complete implementation. There is no other tracking on this site,
because there is no other tracking on this site.

{{ "If you care about this too" | blog_anchor2 }}

You are among friends here. A few things worth your time:

- **[Privacy Badger](https://privacybadger.org/)** - a browser extension from
  the EFF that automatically learns to block trackers. It is what I use.
- **[The Electronic Frontier Foundation](https://www.eff.org/)** - they make
  Privacy Badger and have defended digital rights since 1990. I
  [donate](https://www.eff.org/donate) every year; if you have the means,
  consider it.
- **[EFF's Surveillance Self-Defense](https://ssd.eff.org/)** - plain-language
  guides to protecting yourself, including a good walkthrough of [Android's
  privacy and security
  settings](https://ssd.eff.org/module/how-to-get-to-know-android-privacy-and-security-settings),
  as well as an [iPhone focused version for Apple
  users](https://ssd.eff.org/module/how-to-get-to-know-iphone-privacy-and-security-settings).

If any of this ever stops being true, or you think I have got it wrong, my
address is in the footer and the [socials](/socials/) page has plenty of other
ways to reach me.

{{ "Postscript" | blog_anchor2 }}

One closing remark, since I'm asking you to read the source: you will also find
a single `<script type="application/ld+json">` block in the page. That is
**not** code and your browser never runs it. It is a lump of structured text
that helps search engines summarize the page. It counts nothing, stores nothing,
and contacts no one. I mention it so that finding it does not make you wonder
what else I didn't mention. Nothing.
