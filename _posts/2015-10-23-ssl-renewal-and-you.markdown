---
author: tbielawa
comments: true
date: 2015-10-23 16:54:31+00:00
layout: post
link: https://blog.lnx.cx/2015/10/23/ssl-renewal-and-you/
slug: ssl-renewal-and-you
title: SSL Renewal And You
wordpress_id: 808
categories:
- /dev/null
- Tutorials
tags:
- certificate
- crypto
- csr
- renew
- SSL
---

![RapidSSL_SEAL-90x50](https://blog.lnx.cx/wp-content/uploads/2015/10/RapidSSL_SEAL-90x50.gif)

This post is about renewing SSL certificates. There's not a lot of information I want to communicate here, so I'm going to keep it short.

Yesterday the SSL certificate for `https://blog.lnx.cx` expired. I don't know much about SSL, other than I find it more confusing/complicated than most things. I knew that I needed to renew the SSL certificate for the blog, but I did not know what that exactly meant. When I called my cert provider on the phone to renew, they told me that the renewal process begins with submitting a new [Certificate Signing Request](https://en.wikipedia.org/wiki/Certificate_signing_request), or `CSR` in crypto parlance. We ended the call shortly thereafter and I set off to get started.

I still had questions though. If I'm "renewing" my SSL certificate, does that mean my existing certificate is involved in some way? When I began reviewing the CSR generation procedure I saw no references to existing certificates. I did a bit of Internet research to try and figure this out.

Eventually I found out that the idea of "renewing" a certificate is a bit of a misnomer. That is, nothing you have carries over with you. _The process of "renewing" a certificate is actually the exact same process as getting an initial certificate._ I'll say that again for clarity:


Renewing an SSL certificate is the exact same thing as getting your first SSL certificate.


I hope this helps out other folks who are as confused as I was about the renewal process.
