---
date: 2026-07-12
title: famoe.ly - I wanted a practice set list, what I got was much more
tags:
- Python
- project
- machine learning
- data modeling
- statistics
- probability
- monte carlo
- moe.
- music
- jam bands
- prediction models
- set lists
- archive.org
categories:
- Programming
- Music
- Math
draft: false
author: Tim Case
layout: post
---

👉🏻 [famoe.ly](https://famoe.ly)

I just wanted to create a playlist I can listen to that will most likely have a
solid selection of songs I'm going to hear August 13/14/15. I ended up with a
prob and stats model that has produced close to 90% accurate predictions (*citation needed*, see "Context" below).

{{ "famoe.ly - Nerd Math and Jam Bands" | blog_anchor }}

Back in February this year (2026) my {{ "The Help Coalition Newsletters" |
blog_cross_link: "/2026/06/26/archive.org-THC-collection.html", "Uncle Tim" }}
and I caught the first 2 nights of the opening run of
[moe's](https://www.moe.org/) "Born to Fly" tour, at [Higher
Ground](https://highergroundmusic.com/) in Burlington, VT.

It was great. My only note: I wish we had realized sooner that it was 3 nights,
not 2.

Going into that (unforgettable) experience I felt pretty confident in my
knowledge of moe's catalog. They've been around for about 35 years and primarily
tour, so that's a lot of potential music to keep up with. I was mistaken. There
were a lot of songs they played those two frigid Burlington nights that I wasn't
familiar with. And that's cool, ya know? You're allowed to play music I'm not
familiar with.

**At the time** I didn't feel like I got everything I wanted out of it.

Because of the hard work of the tapers like [Phil
Hernandez](https://archive.org/search?query=taper%3A%22Phil+Fernandez%22) I've
been able to listen to those two nights on repeat (and the third night we
missed) and it's even better than what I remembered. Which was, to be completely
honest, already pretty fucking great.

* [Night 1](https://archive.org/details/moe2026-02-05)
* [Night 2](https://archive.org/details/moe2026-02-06)
* [Night 3](https://archive.org/details/moe2026-02-07)


{{ "Get to the Point" | blog_anchor }}

OK let me stop burying the lede. This update is about the weeks of work I've put
into some data analytics/modeling/probability software. Basically "setlist.fm
but better". I'm going to do my first "follow the band" trip in August and I
wanted to be sure I was familiar with enough of their recent touring catalog to
not get taken by surprise again. *It's just how I enjoy music. Don't knock it.*
So I made a few things.

My objective was to create some kind of script that will generate a pool of a
few dozen songs that are most likely to play on the 3 night run I'm catching
them in August. All I wanted was to create an actual playlist (on the computer)
that I can listen to that *probably* covers most of what I might hear (songs I
wasn't prepared for).

![famoe.ly landing page](/assets/images/famoe-ly-landing-page.png "famoe.ly in large letters with a sun gradient behind them, a page with a cosmic spacey feel for the background. The Songbook and The Scorecard are the options you can select under the header image")

It turns out once you build that foundational model and data pipeline you can
build a lot of other prob and stats stuff with very little extra effort. And
when you add an LLM assistant, you can accelerate that *like whoa*.

{{ "The Scorecard" | blog_anchor }}

[The Scorecard](https://famoe.ly/scorecard/) is a prettier and more useful
version of the first iterations of what the model was producing. This version
keeps history and shows you how the predictions change over time as more results
come in and the model is able to improve its predictions.

![Churn Dashboard Header](/assets/images/churn-dashboard.png "Churn dashboard header")

Here are examples of two nights side by side. You can already see that there's a
lot of data in this. It's a lot more interesting if you load the page and
explore it yourself.

![Two Nights, One Passed, One Not Yet](/assets/images/churn-nightly.png "Model
output for adjacent mights, different data available on the night not yet
recorded in the model. Finalized data and prediction stats displayed on the
model that has data from the actual night")

The model ingests data from 3 sources.

1. Archive.org API
2. Setlist.fm API
3. Machine vision parsing Instagram posts

Data ingestion is weighted in that order. We prefer to build nightly data based
on taper uploads in the [moe. collection](https://archive.org/details/moe) on
[archive.org](https://archive.org). We supplement that with data from setlist.fm
when archive is lacking. And if all else fails we fall back to me personally
feeding a Python parser data from [their Instagram
page](https://www.instagram.com/moetheband/).

Speaking of data. Did you notice that pretty little building icon? Let me show
you a closer screenshot:

![We'll tell you if tapes are up on archive.org](/assets/images/archive-x-linking.png "This Greco-Roman building with the pillars out front will have a number beside it if we have found recordings for this night on archive.org already")

As we parse new data we update the database. That means that when the
predictions are updated we're able to automatically update all churn tables to
give you links to recordings we found on archive.org when we were building the
data set. Obviously this information is not available for dates that haven't
passed yet :-)

The churn dashboard starts at the beginning of June because... I had to start
somewhere. And at the time I was having to manually do a lot of data wrangling.
Eventually my automation was upgraded enough to backport to 2020. It seemed like
a fine place to stop. There's no reason I couldn't extend it back further. I
just don't need data *that* old for what the model is doing.

Speaking of which, what exactly is the model doing?

{{ "What It Does" | blog_anchor }}

The model runs hundreds of thousands of simulations, using time based weights,
decays, and other "dampening" methods to predict future set lists. It's just not
reasonable to predict a 10 track set any given night. They have scores of songs.
Literally hundreds if you're being particular.

That's where The Songbook comes in.

If you filter [The Songbook](https://famoe.ly/songbook/) to just 2026, and only
include `Anchors`, `Core Rotation`, `Regular Rotation`, and `Deep Cuts` you
still end up with 100 songs:

![100 Songs in that Limited Selection](/assets/images/moe-songbook-2026.png "The Songbook demonstrating how it can filter by several groups of song, by regularity, and date range")

What we **can do** is use probability and statistics to create a model for how
they historically write up set lists, and refine our predictions based on that.
We can incorporate a lot of attribute into this, such as venue type, if we're in
"a run" (several nights back to back), and even things like estimated set list
length and historical data. I'm not including **all** of that in the model yet,
it's a work in progress. Some things like learning average song/jam length are
coming in the next iteration. That greatly influences what we could expect to
hear in a given night. You wouldn't put 4 songs that tend to descend into 30+
minute jams into the same prediction for a given night in a small coffee-house
venue. You can also start to look for common segues and absolute exclusions.

Just look at the [performance
history](https://en.wikipedia.org/wiki/Dark_Star_(song)#Performance_history) and
[notable
performances](https://en.wikipedia.org/wiki/Dark_Star_(song)#Notable_performances)
of The Dead's famous jam `Darkstar` on Wikipedia.

Anyway.

{{ "Context" | blog_anchor }}

In the intro I said 

> citation needed, see "Context" below

Here's the context. That "90%" accuracy quote was not a lie, but also not the
**whole** truth. You read this far, strap in for some basic math.

![Cherry-Picking Data](/assets/images/cherry-picking.png "This prediction card says our models hit-rate was 86&, we 'call' 86% of the show")

Earlier I also said that we don't make 10 song predictions when we're building
predictions. We'd never get anything close to useful from that. We actually
build 30 song pools when we make predictions. Each of those has a probability
normalized from 0->1. On average given a `recall@30` we "predict" 8 songs. The
model reports its nightly "expected" rate at about 20-25%, and most of the time
it's spot on. That cherry-picked screenshot above says we called 86% of the
show. But we picked 30 songs. There were only 7 songs played that night

> Side note, that little greek building icon with the `1` next to it means there is 1 recoding on archive.org for that show, you could listen to it right now

When the model says 25% expected, it means it thinks about a quarter of the
songs in the prediction list, the 30-song pool, will show up in the actual
playlist. A lot of the time that turns out to be right. 20-30% of 30 is in the
6-9 song range.

But we didn't produce an artifact that had the exact number of songs in the show
that night.

{{ "recall@100" | blog_anchor }}

I said `recall@30` earlier, that's a tuning parameter of the model. If we make
the number there larger and larger our "hit rate" will increase and approach 1.0
(100%). That's because we would be producing a 100-song prediction pool.

Do you recall what I said earlier about the song book? If you filter to just the
most likely stuff this year, there they have already played 100 songs. It's a
coincidence that recall@100 would get us close to "100%" correct. But it's a
handy way to explain what this model does and DOES NOT do.

The model DOES NOT produce 90% accurate 10-song set lists

The model DOES produce pools of 30 most likely songs, of which about 25% tend to
show up. And sometimes, of those 6-9 songs that might play (it's never the top
6-9% by probability), more than half are actually played.

I'm pretty happy with that.

{{ "The Setlist" | blog_anchor }}

What is the **current** "practice list"?

1. Band in the Sky
2. In Stride
3. Yellow Tigers
4. Buster
5. Letter Home
6. Tailspin
7. Wormwood
8. Lazarus
9. Rebubula
10. Giants
11. Happy Hour Hero
12. Bat Country
13. Meat
14. Downward Facing Dog
15. Head
16. Big World
17. Silver Sun
18. Mexico
19. Captain America
20. Billy Goat
21. Blue Jeans Pizza
22. Plane Crash
23. Moth
24. Ups and Downs
25. Shoot First
26. Haze
27. Seat of My Pants
28. Bring You Down
29. Okayalright
30. Puebla
31. The Pit
32. Not Coming Down
33. Wind It Up
34. Kyle's Song
35. Timmy Tucker
36. Water
37. Recreational Chemistry
38. Tomorrow Is Another Day
39. Bullet
40. New Hope for the New Year
41. All Roads Lead to Home
42. George
43. Gone

Most nights they play the prediction churn model only shuffles about
probability. Every now and then a few songs enter or exit.

But right now, this is the most likely set of songs I'll hear on August 13/14/15
(and maybe you too!)

> To be clear, the model generates this list doing a union across the 3 most
> likely 30-song pools across those 3 nights.

