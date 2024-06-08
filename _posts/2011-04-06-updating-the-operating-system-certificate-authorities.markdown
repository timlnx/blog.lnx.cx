---
author: Tim Bielawa
date: 2011-04-06 23:16:24+00:00
layout: post
published: false
title: Updating the Operating System Certificate Authorities
categories:
- /dev/null
tags:
- Fedora
- Google Chrome
- Mozilla Firefox
- Red Hat
- SSL
- TLS
---

Today I finally had enough of these messages about internal websites not having their root certificate authority in the operating systems know authorities list. I started scouring Red Hat's bugzilla bug tracker for a solution. My question was clear: How do I properly add a new certificate authority so that all applications on my system can make use of it?

I'm running Fedora 14 right now. It appears that CAs are under /etc/pki/tls/certs/. But how are you supposed to store certs? I had read some where about some kind of hash-based symlink system, but I've never read anything that made me feel like I was reading "The definitive guide."

During my research I remembered that Firefox (and crew) doesn't utilize the operating systems hash-named symlinked based CA tree. Firefox uses a system called NSS, or Network Security Services, to keep track of its CAs.

Well, after digging through bug trackers following links the trail eventually dead-ended on this bug: [Bugzilla: 620752](https://bugzilla.redhat.com/show_bug.cgi?id=620752), _Review Request: update-ca-certificates - A tool to manage systemwide CA certificates_. At first I didn't believe it. This never happens. I expected to see it stuck in sponsorship limbo, or never seeing completion because of excessive bike-shedding. But I was wrong, and it felt so good to be wrong.

I downloaded my internal CA cert and went about installing it with my new friend, update-ca-certificates


<blockquote>[root@fridge certs]# update-ca-certificates -ani redhat-is-ca.crt
INF: Creating link from /etc/pki/tls/certs/a275a5bb.0 to /etc/pki/CA/certs/redhat-is-ca.crt
INF: Adding certificate from /etc/pki/CA/certs/redhat-is-ca.crt to shared system NSS</blockquote>


I launched Firefox and everything was working the way I expected it to. No more scary messages. I had the root certificate installed and Firefox was using it.

Of course, at that very moment Google Chrome decided to be stubborn. Google Chrome did not read the system wide hash-symlinked CA tree, NOR, did it recognize my new CA from the system wide NSS database. There's no excuse for this kind of behavior in my opinion. I hope I was just doing something wrong.

Anyway, running version 10.0.648.204 the solution was easy enough to solve. Go to **Preferences** and then **Under The Hood** and go into **Manage Certificates** in the "Security" section. From there just click on **Authorities** and then **import** to select the new CA certificate you want to have Chrome recognize when verifying SSL certificates.
