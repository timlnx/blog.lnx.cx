---
author: Tim Bielawa
date: 2024-06-27
layout: post
title: "GPS Mapping Chicago Trails — Part 1: Schiller Woods"
tags:
- project
- gps
- gpx
- trails
- maps
- hiking
---

This is part 1 in a series of blog posts where I am taking a deep dive into the
world of GPS trail mapping. In this part of the series we're going to introduce
the subject forest I will be mapping and explore my motivation for this project.

* [GPS Mapping Chicago Trails — Part 1: Schiller Woods]({% link _posts/2024-06-27-gps-mapping-chicago-trails-part-1.markdown %})
* [GPS Mapping Chicago Trails — Part 2: Software]({% link _posts/2024-07-04-gps-mapping-chicago-trails-part-2-software.markdown %})
* [GPS Mapping Chicago Trails — Part 3: Putting It All Together]({% link _posts/2024-07-06-gps-mapping-chicago-trails-part-3.markdown %})

{{ "Intro" | blog_anchor }}

Recently I've been spending time walking the trails in [Schiller Woods
South](https://fpdcc.com/places/locations/schiller-woods/), a section of the
[Forest Preserve District](https://fpdcc.com/) located in the Chicago suburbs.
Specifically, I have been starting my walks at "Hidden Hill" which is accessed
via the [Che-Che-Pin-Qua
Woods](https://fpdcc.com/places/locations/schiller-woods/#3103) entrance on
Irving Park Road.

![Hidden hill, bet you didn't even know it was there, very sneaky!](/assets/images/hiddenhill.jpg "Hidden Hill")

My birthday passed recently. To celebrate I took that week off from work. With
this free time I thought that I could go map the trails in these woods and post
them all online for people to enjoy. I had several days set aside for this and
all that I had to do was walk just a *few* miles of trails, post-process the
data, and get it uploaded. How hard could it be?

Nominally speaking, it's not very difficult at all to record some GPS tracks and
upload them online. As the saying goes, `there is an application for that`.
However, for the case of Schiller Woods South ("SWS" from now on), this turned
into a series of rabbit holes, emails, and a lot of unexpected learning.

In this post I will try to distill what I learned. If you find that you are
interested in this kind of project yourself then you may find this information
useful. If not, then stick around for the trail pictures and pretty maps.

![Schiller Woods South - Ad-hoc shelter](/assets/images/sws-structure.jpg "Ad-hoc shelter")

{{ "Why is this Interesting?" | blog_anchor }}

Why did I find this interesting enough for me to post about it? Because of
**inconsistency** and **incompleteness**. The data available drove me mad. Let's
go on a brief tangent, shall we?

At first I thought that the trails in SWS weren't documented online at all. In
fact, if you take the [Web
Map](https://map.fpdcc.com/#/?poi=223-Che+Che+Pin+Qua+Woods) link from the FPCC
(Forest Preserve of Cook County) page for this region, you won't find any
evidence of the trails I am talking about.

![Forest Preserve District of Cook County Web Map. Credit: FPCC](/assets/images/fpdccmap.png "No trails here")

For a reasonable person this would be the natural conclusion. The official
source does not document the trails. Therefore, they are unofficial. But then I
found this when I pulled in OpenStreetMaps data to overlay my first GPS
recording over.

**Trails**. Many trails.

Some of these trails you see below were added [almost 14 years
ago](https://www.openstreetmap.org/way/79159562/history/1) on [OpenStreet
Maps](https://www.openstreetmap.org/#map=16/41.9476/-87.8456). Some trail data
have been added or edited as recently as 2 years ago. Some trails you can walk in
real life aren't represented here.

![Schiller Woods South trails. Credit: OpenStreetMaps](/assets/images/schillerwoods-osm.png "Schiller Woods South trails as seen on OpenStreetMaps")


I wish I could have seen it back then, before the Japanese Barberry established
itself.

> "What's Japanese Barberry?"

{{ "Japanese Barberry" | blog_anchor_link: "We'll get to that." }}

If you go to the Hiking Project (app or website) you can see that there are some
trails in a section that's labeled [Schiller Woods
South](https://www.hikingproject.com/directory/8017260/schiller-woods-south).
However, these trails aren't in Schiller Woods **South**.

![Documented trails on for other areas. Schiller Woods South identified in rectangle at bottom of image. Credit: HikingProject.com](/assets/images/documented-trails.png "Documented trails for other areas")

Conspicuously missing are entries of the *actual* trails in the SWS region. The
spurs and trails displayed in that image are in the Schiller Woods West and East
regions, as well as the Robinson Woods and Catherine Chevalier woods regions.

Now what really chaps my ass about this is that the [Forest Preserve of Cook
County](https://www.hikingproject.com/user/7040419/forest-preserves-of-cook-county)
itself was the one uploading the data to the Hiking Project. As of 2024-06-28,
FPCC is #55 with 1,668 points on the Hiking Project contributions [leader
board](https://www.hikingproject.com/directory/users).

Unfortunately, it seems that their time with Hiking Project has come to an end.
Their profile lists their join date as March 2016 and their last visit to the
site as July 2018.

> Don't get me wrong, I do appreciate their significant contributions, I'm sure
> that was a massive boon to the project at the time and helped it grow quite a
> bit. I just include this as a record of the things that drove me mad as I was
> starting this project.

Oh yeah, that's right. We were talking about my mapping project weren't we?

![Schiller Woods South - Oh dear!](/assets/images/sws-oh-dear.jpg "Oh dear!")

I have broken this subject into a series of posts because I would have never
finished if I tried to write it all at once.

If you've enjoyed the story thus far, please join me in [part
2](/2024/07/04/gps-mapping-chicago-trails-part-2-software.html) where I begin
exploring assorted GPS software and the GPX data exchange format. It's
thrilling.





