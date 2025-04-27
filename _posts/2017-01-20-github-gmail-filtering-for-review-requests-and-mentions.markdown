---
author: Tim Case
date: 2017-01-20 19:43:50+00:00
layout: post
title: '[Updated] GitHub + Gmail — Filtering for Review Requests and Mentions'
categories:
- Planet
- Programming
- Tutorials
tags:
- Filtering
- GitHub
- Gmail
- Gmail labels
- Mentions
- Pull Requests
- Reviews
---

# Update - 2017-01-27


Just 3 days after publishing this blog post GitHub made a new blog post:


<blockquote><a href="https://help.github.com/articles/about-pull-request-reviews/" target=_blank>Pull request reviews</a> are a great way to share the weight of building software, and with <a href="https://help.github.com/articles/requesting-a-pull-request-review/" target=_blank>review requests</a> you can get the exact feedback you need.</blockquote>

To make it easier to find the pull requests that need your attention, you can now [filter by review status](https://help.github.com/articles/filtering-pull-requests-by-review-status) from your repository pull request index.</blockquote>

Source: [Filter pull request reviews and review requests](https://github.com/blog/2306-filter-pull-request-reviews-and-review-requests)

I have tried this out and it's great! Like most everything else on GitHub it's very intuitive and simple to use. I won't steal their thunder and describe it all here. So [go check out the blog post for yourself](https://github.com/blog/2306-filter-pull-request-reviews-and-review-requests) and read up on the details (screenshots included!).


# The Problem

I've been looking for a way to filter my GitHub Pull Request lists under the condition that **a review is requested of me**. The online docs didn't show any filter options for this, so I checked out the [@GitHubHelp](https://twitter.com/GitHubHelp) twitter account. The answer was there on the front page — they don't support filtering PRs by `review-requested-by:me` yet:


<blockquote><a href="https://twitter.com/zaghnaboot" target=_blank>@zaghnaboot</a> Adding a filter for reviewers is definitely on our radar, though I don't have a specific timeline to share. --SJ

— GitHub Support (@GitHubHelp) <a href="https://twitter.com/GitHubHelp/status/822203227395518464" target=_blank>January 19, 2017</a></blockquote>




So what is one to do? I'm using Gmail so I began considering what filter options were available to me there. My objectives were to clearly label and highlight:



 	
  *  PRs where review has been requested

 	
  * Comments where I am `@mention`'d


## Review Requested


Applying labels for PRs where a review is requested of me is a little hacky, but the solution I came up with works well enough. When your review is requested you should receive an email from GitHub with a predictable message in it


<blockquote>@kwoodson `requested your review on:` openshift/openshift-ansible#3130 Adding oc_version to lib_openshift..</blockquote>


That highlighted part there, `requested your review on:`, is the key.

In Gmail we're going to add a new filter. You can reach the new filter menu through the settings interface or by hitting the subtle little down-triangle (▾) left of the magnifying glass (🔍) button in the search bar.



 	
  * In the "**Has the words**" input box put (in quotes!): `"requested your review on:"` (You can pick a specific repo if you wish by including it in the search terms)

 	
  * Press the `Create filter with this search »` link


[![](https://blog.lnx.cx/wp-content/uploads/2017/01/Screenshot-from-2017-01-20-11-37-35-640x401.png)](https://blog.lnx.cx/wp-content/uploads/2017/01/Screenshot-from-2017-01-20-11-37-35.png)



 	
  * Use the "**Apply the label**" option to create a new label, for example, "Review Requested"

 	
  * You might want to check the "**Also apply filter to _X_ matching conversations**" box

 	
  * Create the new filter


[![](https://blog.lnx.cx/wp-content/uploads/2017/01/Screenshot-from-2017-01-20-11-37-20-640x391.png)](https://blog.lnx.cx/wp-content/uploads/2017/01/Screenshot-from-2017-01-20-11-37-20.png)


## Mentions


Labeling `@mention`'s in Gmail is a little easier and less prone to error than the review request filter could be. It also follows a similar process.



 	
  1. Create a new filter

 	
  2. In the "**To**" input box put: `Mention <mention@noreply.github.com>`

 	
  3. Press the `Create filter with this search »` link

 	
  4. Continue from **step 4** in the previous example





