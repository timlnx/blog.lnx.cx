---
author: Tim Bielawa
date: 2024-06-27
layout: post
title: "DRAFT: GPS Mapping Chicago Trails"
tags:
- project
- gpx
- gpx
- recording
- trails
- maps
- hiking
---

Strap yourselves in folks, I can tell this is going to be a long one.

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

Why is this interesting enough for me to post about it? Because of
**inconsistency** and **incompleteness**. The data available drove me mad. Let's
go on a brief tangent, shall we?

At first I thought that the trails in SWS weren't documented online at all. In
fact, if you take the [Web
Map](https://map.fpdcc.com/#/?poi=223-Che+Che+Pin+Qua+Woods) link from the FPCC
(Forest Preserve of Cook County) page for this region, you wont't find any
evidence of the trails I am talking about.

![Forest Preserve District of Cook County Web Map. Credit: FPCC](/assets/images/fpdccmap.png "No trails here")

For a reasonable person this would be the natural conclusion. The official
source does not document the trails. Therefore, they are unofficial. But then I
found this when I pulled in OpenStreet Maps data to overlay my first GPS
recording over.

**Trails**. Many trails.

Some of these trails you see below were added [almost 14 years
ago](https://www.openstreetmap.org/way/79159562/history/1) on [OpenStreet
Maps](https://www.openstreetmap.org/#map=16/41.9476/-87.8456). Some trail data
have been added or edited as recently as 2 years ago. Some trails you can walk in
real life aren't represented here.

![Schiller Woods South trails. Credit: OpenStreet Maps](/assets/images/schillerwoods-osm.png "Schiller Woods South trails as seen on OpenStreet Maps")

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

{{ "Getting Started" | blog_anchor }}

Part of my motivation for starting this project was the lack of available
information of what was out there to walk in Schiller Woods South. Google maps
didn't have anything listed, and some of the trails got kinda sketchy. You could
be pretty sure that people were walking there before, but if you went much
farther it could become less clear where to go next.

This is what prompted my search for trail recording software. If I couldn't find
existing trail maps, then I would make my own.

My mobile device is a Samsung Galaxy S22 Ultra running stock Android 14. I like
this device quite a bit. What I like most of all about it is the super crisp
display and the excellent photos the camera captures. This is what I used to
record the trail GPS data. Yeah, the GPS hardware in it isn't professional
grade, but I didn't need that to go out and have some fun.

> But to be clear, I did attempt to make an impulse purchase that weekend for a
> proper GPS recording device and got blocked by the lack of options I could
> actually drive to. REI and Best Buy near me were only carrying fitness devices
> with basic GPS viewing functionality.

![Schiller Woods South - Oh dear (2)!](/assets/images/sws-oh-dear2.jpg "Oh dear (2)!")

I didn't need anything fancy as far as software goes, my requirements were quite
modest:

* Record GPS data in some portable format
* View GPS data over a map
* Optional: annotate data with pins

Unsurprisingly it turns out that most software in the app stores are loaded with
ads and pushy in-app purchases. This post is not about those apps. I avoided
those apps. This post is about these nice apps that I enjoyed using.

{{ "TrekMe" | blog_anchor }}

The first app I installed is called [TrekMe - GPS trekking
offline](https://play.google.com/store/apps/details?id=com.peterlaurence.trekme).
It does not annoy me to use it. As in, there are no ads, or constant begging to
upgrade to the paid experience. It satisfies all of the requirements I outlined
above. The paid upgrades are for higher resolution map data which I didn't need.
I like this app and I still use it.

Fun fact: if the author's name, Pierre Laurence, didn't give it away already,
you can tell this app was made by a french person because of the prefix unit it
uses when showing you how large the map data download will be.

I learned this many years ago on my python "bitmath" project when a user
submitted an RFE on github requesting support for [parsing french unit
names](https://github.com/tbielawa/bitmath/issues/53). I guess over there they
say octets in speech instead of bytes. Neat!

![TrekMe says the map download size is 7 Megaoctets](/assets/images/trekme-mo.jpg "TrekMe says the map download size is 7 Megaoctets")

This post isn't about in-depth app reviews. So, in brief, TrekMe records GPS
data in a standard file format that I could easily export. The user experience
is a little clunky, but it works and is not obtrusive. And it's free. I like
that. There are screenshots on the google play store if you want to see more.

TrekMe is also how I found out about the known and already mapped trails in SWS.
I discovered this when I was creating a new recording one day and selected a
different source for the map data. Previously I used the U.S. Geological Survey,
this next time I tried the OpenStreetMap data.

{{ "What is this Recording Data Anyway?" | blog_anchor }}

What format is a GPS recording? It's XML. But it's ok, hear me out. It's OK
because it's actually standardized and big companies stick to the standard which
makes the data very portable. But, best of all, there is an actual XML schema
published that you can stick into your editor and use for real-time validation.

Wait what? Stick into your editor? I thought the device made the recording file?
Yes, that is true. My device did do all of the recording for me. But I'm a geek
who had to keep looking behind the curtain to understand the next layer of
technology.

The XML format for GPS data is called GPX, the [GPS Exchange
Format](https://www.topografix.com/gpx.asp). The current schema version is GPX
1.1. It is free and open and I love that. You could look at the [XSD
schema](https://www.topografix.com/gpx/1/1/gpx.xsd) right now if you want to.
But they didn't stop there, they actually published [useful
documentation](https://www.topografix.com/gpx/1/1/). Coming from a person who
has written thousands of pages of documentation, this is a big compliment.

Here's a simple truncated example of a fully formed document with two track
points I recorded myself:

{% highlight bash %}
<?xml version="1.0" encoding="utf-8"?>
<gpx version="1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns="http://www.topografix.com/GPX/1/1"
        xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"
        creator="TrekMe">
    <metadata>
        <name>combo</name>
        <time>2024-06-16T09:10:30</time>
    </metadata>
    <trk>
        <name>redloop</name>
        <trkseg>
            <trkpt lat="41.9508266" lon="-87.8457736">
                <ele>157.9826350599507</ele>
                <time>2024-06-13T23:18:12</time>
            </trkpt>
            <trkpt lat="41.9508045" lon="-87.8457403">
                <ele>158.78511764077382</ele>
                <time>2024-06-13T23:18:15</time>
            </trkpt>
        </trkseg>
    </trk>
</gpx>
{% endhighlight %}

OK, you **can** use it in your editor if you're a lunatic like me. But more
likely you would use the schema in an application that is dealing with GPX data
and wants to ensure that every recording it produces (or is ingesting) is a
compliant and valid file.

While we're talking about it, I want to mention that I also installed the [VS
Code "XML"
plugin](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-xml),
which coincidentally was made by my former employer, Red Hat. I did not expect
that.

The plugin worked for me. It identified the schema in the GPX document and
validated the file automatically. When I was shifting tracks and segments around
manually it was correctly pointing out invalid syntax errors and giving valid
element and attribute suggestions. Well done.

{{ "Avenue GPX Viewer" | blog_anchor }}

I wanted a GPX viewer on my computer as well. For a few hours while walking the
trails I considered how I would write my own *shitty* browser-based track
viewer. Eventually I came to my senses and settled on finding an actual
application that was already written.

At the time of writing I am rocking a stately 2022 M2 MacBook Air, running macOS
14.5 (Sonoma). Again, my requirements, were modest:

* Load GPS recording
* Overlay recording on a map

I think this search was easier than finding TrekMe on my phone. Pretty quickly I
found [Avenue](https://github.com/vincentneo/Avenue-GPX-Viewer) in the App
Store, saw that it was simple, free, **and open source**, so I installed it.

There's not much to say about it, so let me show you instead:

![Avenue adds map preview in finder](/assets/images/avenue-finder-preview.png "Avenue adds map preview in finder")

Above you can see that Avenue is capable of making the GPX file icons a preview
of their routes, and the `[spacebar]` preview menu function works as well.

![Avenue open with the map selection widget displayed](/assets/images/avenue-open-app.png "Avenue open with the map selection widget displayed")

Above I have Avenue open with one of my recordings. There are actually several
different track segments in the file I opened. It is correctly displaying them
all at once. You can also see the minimap preview and the map source selector.

I noticed while writing this post that the author of Avenue actually contributed
to another project, [Open GPX
Tracker](https://github.com/merlos/iOS-Open-GPX-Tracker), which is also free and
open source, and has no ads or in-app purchases. If I had an iPhone I would try
this for recording my data.

Thank you Vincent Neo! Avenue is great. I absolutely recommend it.

![Schiller Woods South trail obstruction](/assets/images/sws-trail-obstruction.jpg "Schiller Woods South trail obstruction")

{{ "GPS Logger" | blog_anchor }}

[GPS
Logger](https://play.google.com/store/apps/details?id=eu.basicairdata.graziano.gpslogger)
is another android app that I used. I think I saw a reference to it on an ATV
forum. It is quite different from how TrekMe works. It does not include any
maps, it is pure data acquisition.

It allows you to adjust the capture frequency slightly and allows you to export
in plain text, GPX, and KML ([keyhole markup
language](https://en.wikipedia.org/wiki/Keyhole_Markup_Language)) formats. It
also includes altitude correction features. There are no ads and there are no
in-app purchases.

I like GPS Logger. It does one thing and it does it very well. In particular I
like that the main recording screen contains all of its buttons in a single row
and you can lock out that row from accidental pushes while you're recording. The
data display is quite useful.

![GPS Logger interface](/assets/images/gps-logger.jpg "GPS Logger interface")

{{ "Hiking Project" | blog_anchor }}

I mentioned earlier that I tried [Hiking
Project](https://play.google.com/store/apps/details?id=com.hikingproject.android).
To be completely honest, it's kind of annoying to use. It felt difficult to
locate, select, and do anything useful with tracks.

It did let me record my own tracks. But it wants to integrate with the online
service when I just wanted to record something for myself. Maybe I was doing
something wrong.

It didn't help my experience when The Forest Preserve group had multiple trails
and spurs entered with the **same name**, so when Hiking Project asked me which
trail I was on I had 3 choices with the **same name** and no context to indicate
which forest they're in.

![Schiller Woods South - Looking Northwest at Hidden Hill](/assets/images/sws-hidden-hill-northwest.jpg "Schiller Woods South - Looking Northwest at Hidden Hill")

{{ "gpx studio" | blog_anchor }}

Allow me to introduce you to [gpx studio](https://gpx.studio/). When I found
this I was immediately confident that my earlier decision to not write my own
browser-based viewer was the correct choice.

This tool **kicks ass**. And it's free! **AND** It's [open
source](https://github.com/gpxstudio/gpxstudio.github.io)! I could fill up
another page here writing out everything it does, so instead I'll strongly urge
you to go to the project's [about page](https://gpx.studio/about.html#about) and
look at the list yourself.

![GPX Studio](/assets/images/gpx-studio.png "GPX Studio")

{{ "Putting it all Together" | blog_anchor }}

At this point I have accumulated close to 40 miles walking those trails. Each
trip out there I improved my collection method and refined my routes. I learned
more about the forest and slowly developed an idea of what's missing. I also
began to suspect that something was not quite right.

What do I mean by "not quite right"? After talking with some friends for a while
we noticed that there are no clear and obvious "main trails". In other words,
there are no indicated begin and end points. This is an issue.

Let's step backwards a bit, I'm going to introduce some language from the GPX
specification because the specification captures the way that people commonly
conceptualize trails. It also codifies how we must handle trails in our
software.

* `<trkseg>` - A Track Segment holds a list of Track Points which are logically connected in order
* `<trk>` - Represents a track - an ordered list of points describing a path

A `<trk>`, track, is "the trail" you're hiking. For a simple out and back trail
([types of trails](https://www.advnture.com/features/types-of-hiking-trails)) you
just have one `<trkseg>` in your `<trk>`. The track segment contains **all** of
the points from the starting location to the ending location. These points are
in order.

Now let's say that there are little trails shooting off of the sides of your out
and back trail. Each of these offshoots would be another `<trkseg>` that starts
at a point on the main `<trkseg>`. Logically they are connected in some way to
the main trail you are on. Sometimes these are called "spurs".

You might also have connectors which *connect* two main trails together. The
connector segment only exists because the other main segments exist.

A good trail will typically have [trail indicators
posted](https://www.greenbelly.co/pages/how-to-read-hiking-trail-signs-markers-blazes).
Sometimes they're symbols on trees (these are called blazes), sometimes they're
piles of stones (cairns), or maybe just posts in the ground.

I spent two days with a clipboard and a pen, walking every single trail again
trying to find the signal in the noise.

![Blazes and trails](/assets/images/sws-signal-noise1.jpg "Blazes and trails")

I examined every blaze. I noted their patterns and locations.

![Gallery of Blazes](/assets/images/sws-blazes.png "Gallery of Blazes")

I was not making any progress. 

![Blazes and trails](/assets/images/sws-signal-noise2.jpg "Blazes and trails")

I asked a friend for advice about the blazes.

> "I don't know. Those are pretty crap" - my friend

He was right. They are pretty crap.

Schiller Woods South has nothing consistent or complete.

It is absolute chaos.

It is unfocused.

It is crisscrossing lunacy.

Let's take a break. Let's talk about something nice for a minute. Like getting
thorns in your hands, and invasive species.

{{ "Japanese Barberry" | blog_anchor }}

![Japanese Barberry](/assets/images/sws-barberry.jpg "Japanese Barberry")

> "The dense stands of Japanese barberry effectively become a monoculture,
> replacing the diverse, native understory with one species. Japanese barberry
> invasion reduces the carrying capacity of wooded pasture and limits the
> movement of livestock. Cattle and other large animals cannot move through the
> thorny thickets."

- [Minnesota Department of Agriculture](https://www.mda.state.mn.us/plants/pestmanagement/weedcontrol/noxiouslist/japanesebarberry)

Yeah. It sucks. And Schiller Woods South is getting overran with the stuff. In
the photo above we have an example of its invasive spread. I am 6 feet tall and
some of those plants come up to my shoulders. The floor of the forest is no
longer visible. The root of each barberry becomes a hive of scum and
~~villainy~~ ticks.

The barberry creates an interconnected underground network of rhizomes --
horizontal underground plant stems capable of growing another plant. That's
right, it's like a hydra. You cut off one head and more come to replace it.

Also, those fuckers are covered in thorns 🖕🏻 (technically they're covered in
spines).

It's not all bad though:

![Less Japanese Barberry](/assets/images/sws-less-barberry.jpg "Less Japanese Barberry")

Much of the center area on the south side of Schiller Brooke, directly opposite
of Hidden Hill is still gorgeous.

{{ "Sorting out the Mess" | blog_anchor }}

What happened with all that GPS data and the messy trails? I talked with some
friends about it and they suggested reaching out to someone official who can
answer with authority about the situation. Primarily I needed to focus on
answering the question "is there an intended route through this forest?"

I reached out to the people at the Forest Preserve of Cook County:

>  Hello, I would like to know if the trails in Schiller Woods South have names
>  or identifiers, and if there are any intended routes.
>
> Specifically region bordered on the North and South by Irving Park Road and
> the Indian Boundary Golf Course, and bordered on the East and West by N
> Cumberland Ave and the Des Plaines River.
>
> I've noticed there are some markings on some trees but they are inconsistent
> and do not cover any of the paths entirely.
>
> There seems to be a blue and yellow bullseye around a triangular path sequence
> in the middle. And there are red arrows going kind of mostly east and east.
>
> Do these have names, or is there any intended route? I ask because I want to
> do some GPS recordings and upload them online, but because the paths aren't
> very clear there's no obvious way to name or label anything.
>
> Thanks so much!

A few days later I received a brief response which did not directly answer any
of my questions.

>  Hi Tim,
>
> Thank you for reaching out to the Forest Preserves of Cook County.
>
> Typically, we do not name trails (one exception would be at our nature
> centers) but instead use colors to differentiate between trail segments within
> a larger named trail system. Any official trail signage on the ground
> (intersection posts, confidence markers, etc.) should include corresponding
> colors to match the official trails we publish on our maps, webmap and
> website:
>
> [https://fpdcc.com/places/trails/des-plaines-river-trail-system/](https://fpdcc.com/places/trails/des-plaines-river-trail-system/)

I wasn't satisfied with this response so I probed further.

> * Does all this mean that the trails in Schiller Woods South aren't official then?
> * Do you have any official records or documentation of the myriad trails down there?
> * These trails do exist, but just aren't documented. What does that mean about their protected or maintenance status?
>
> Thank you so much for your time! I enjoy these woods and I appreciate your earlier response.

After a few days went by I bumped the email thread and this time I received a
much more complete response. The answers were not the ones I had hoped to
receive.

> Correct. The trails in the southern region are not official Forest Preserves
> trails, but rather, unmarked trails on our website and web map. Here's some
> more information regarding unofficial trails that may be of interest:
> 
> > In addition to designated paved, graded, and primitive/rustic trails, there
> > are many non-designated trails throughout the Forest Preserves. Such
> > non-designated trails may occur naturally as deer trails or through human
> > foot traffic over time. The Forest Preserves does not encourage, but
> > generally does not prohibit, the use of non-designated trails. Users of such
> > trails, however, should note that the Forest Preserves does not inspect or
> > maintain non-designated trails. Accordingly, hidden and latent dangers, as
> > well as other hazardous conditions, may be encountered on non-designated
> > trails. Users of non-designated trails do so at their own risk and are
> > encouraged to minimize their use of such trails. (Source:
> > [https://fpdcc.com/about/rules-regulations/trail-risk-statement/](https://fpdcc.com/about/rules-regulations/trail-risk-statement/))

I enjoy this next part. It seems that the staff are unsure about those pretty
crap blazes I observed before:

> As for the markers you've encountered, and upon reviewing internally with
> staff, it has been relayed that these likely are not official markers—and may
> be the work of local cub scouts or other groups. If possible, please forward
> along any photo references you may have for Forest Preserves staff to confirm,
> or if you don't have any on-hand, we can ask that our staff take a look and
> confirm on that end.

In a followup response I provided a gallery of about 50 photos I took of all the
"not official markers" for their review.

The response continues:

> In conclusion, the only official trail running through this area is the yellow
> unpaved trail (part of the Des Plaines River Trail System) running north to
> south from Irving Park Road to Belmont Ave. Any other trails in this area
> would be considered unrecognized, unofficial trails.  These trails were likely
> formed without Forest Preserves’ consent and are not published on our maps
> because they present a variety of issues (unmaintained, may occur in
> ecologically sensitive areas that cause damage to the environment, etc.).
> Forest Preserves visitors are encouraged to only use our official trails.

There you have it. Those trails are unofficial. Their use use discouraged, but
not prohibited.


{{ "What about that OpenStreetMaps Data?" | blog_anchor }}

I'm glad you asked. Because I'm curious about that too.