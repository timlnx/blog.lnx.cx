---
author: Tim Case
date: 2025-02-09
title: Backing Up YouTube for Fun and Profit
layout: post
tags:
- youtube
- yt-dlp
- media
- archiving
- backups
---

Offline archiving of YouTube videos is possible with this "feature-rich command
line tool" called [yt-dlp](https://github.com/yt-dlp/yt-dlp). Maybe you suffered
a local data loss and you want to recover your uploads

Or maybe you just don't trust companies anymore and want to have a local copy of
everything you love before it's all taken away from you. You do you 👍🏻, I
won't judge.

Here's a command I've cooked up that helped me archive a channels worth of
content in a date-sortable list.

```
$ yt-dlp -S vcodec:h264,res,acodec:m4a -N 4 --cookies-from-browser firefox --output "%(uploader)s - %(upload_date>%Y-%m-%d)s - %(title)s [%(id)s].%(ext)s" https://www.youtube.com/@TimBielawa/videos
Extracting cookies from firefox
Extracted 574 cookies from firefox
[youtube:tab] Extracting URL: https://www.youtube.com/@TimBielawa/videos
```

Why those option flags though?

* `.webm` doesn't integrate well with my current tech stack

Using `-S vcodec:h264,res,acodec:m4a` [is one
way](https://github.com/yt-dlp/yt-dlp/issues/8322#issuecomment-1755932331) to
get `yt-dlp` to avoid leaving `webm` files on your disk. I have no personal
issues with that AV container, it just doesn't integrate well into my stack.
MP4s are seamless, so I am archiving in that format.

* Archive faster, maybe

Attempt concurrent downloading with `-N 4` to download 4 video fragments
simultaneously. Anecdotally I think this has got me throttled before, but that
could be a false memory. tl;dr - try turning this option off, or changing the
number to see what you can get away with.

* Save the archive sortably

I would like my archive stored in a way that is easy to sort chronologically (by
date uploaded). The default `yt-dlp` behavior will save videos with file names
like `<video title> [<video id>].<ext>`, and that doesn't sort very well. That
is why I use this format instead: `--output "%(uploader)s -
%(upload_date>%Y-%m-%d)s - %(title)s [%(id)s].%(ext)s"`. Thanks to [this
post](https://superuser.com/a/1754292) for saving me the time to learn the
[output template variables](https://github.com/yt-dlp/yt-dlp#output-template)
myself.

* Authenticate as myself

By passing in `--cookies-from-browser firefox` I can interact with the YouTube
API as myself and save my private unlisted videos. If you see a message like
`ERROR: unable to download video data: HTTP Error 403: Forbidden` then that's
probably what you're running into.