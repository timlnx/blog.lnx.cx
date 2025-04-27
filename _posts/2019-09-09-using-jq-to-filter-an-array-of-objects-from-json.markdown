---
author: Tim Case
date: 2019-09-09 17:18:50+00:00
layout: post
title: Using jq to filter an array of objects from JSON
categories:
- /dev/null
- GNU/Linux
- Programming
tags:
- amazon
- array
- filter
- jq
- json
- list
- map
---

For some reason it took me an unreasonable amount of time to figure out how to filter an array (or list) of objects from a JSON stream. Every single example I found was a little too weird for me, or resulted in printing each object, but not in a final array format. Here's what I came up with:

Say for example you are parsing the [AWS IP ranges JSON stream](https://aws.amazon.com/blogs/aws/aws-ip-ranges-json/), you will receive an object like this:

{% highlight json %}
{
  "syncToken": "1567728788",
  "createDate": "2019-09-06-00-13-08",
  "prefixes": [
    {
      "ip_prefix": "18.208.0.0/13",
      "region": "us-east-1",
      "service": "AMAZON"
    },
{% endhighlight %}

I was attempting to filter this down to ONLY objects where the `service` attribute was `AMAZON`. Using this jql I would get objects printed one after the other which is not what I wanted:

{% highlight bash %}
$ jq -c '.prefixes[] | select(.service=="AMAZON")' < ip-ranges.json | head
{"ip_prefix":"18.208.0.0/13","region":"us-east-1","service":"AMAZON"}
{"ip_prefix":"52.95.245.0/24","region":"us-east-1","service":"AMAZON"}
{"ip_prefix":"99.77.142.0/24","region":"ap-east-1","service":"AMAZON"}
{% endhighlight %}

The correct syntax was ultimately very similar. 

{% highlight bash %}
$ jq '.prefixes | map(. | select(.service=="AMAZON"))' < ip-ranges.json | head
[
  {
    "ip_prefix": "18.208.0.0/13",
    "region": "us-east-1",
    "service": "AMAZON"
  },
{% endhighlight %}

Now we are getting each object returned as a member of an array. The difference is that we're putting the `.prefixes` array objects into the `map` function and telling it to iterate every object through the `select` function. The `map` takes all of those matching objects and returns them as an array, whereas, previously we were only selecting objects that matched our `select` criteria. To get the objects back in a list we required the `map`.
