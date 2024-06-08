---
author: Tim Bielawa
date: 2013-05-01 19:09:03+00:00
layout: post
title: Rails, Bootstrap, Icons, and Classes
categories:
- Documentation
- Planet
- Programming
tags:
- bootstrap
- css
- ERB
- html
- ruby on rails
---

# Scope




You're using [Ruby on Rails](http://rubyonrails.org/) and the [Twitter Bootstrap](http://twitter.github.io/bootstrap/) framework. You are using the [link_to](http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to) ActionView helper method. The generated anchor will be visually represented in [a navbar](http://twitter.github.io/bootstrap/components.html#navbar) as a Bootstrap [button component](http://twitter.github.io/bootstrap/base-css.html#buttons) (via the '**btn**' and '**btn-small**' class attributes). Finally, you want to use one of those [sweet Boostrap icons](http://twitter.github.io/bootstrap/base-css.html#icons) instead of text. It should look something like this:




[caption id="attachment_427" align="aligncenter" width="412"][![RNOC Action Bar](https://blog.lnx.cx/wp-content/uploads/2013/10/rnoc-button-bar.png)](https://blog.lnx.cx/wp-content/uploads/2013/10/rnoc-button-bar.png) RNOC Action Bar[/caption]


# The Problem




I had difficulty understanding the correct way to call the link_to method to get the results I desired. Part of my failure to [grok](http://www.catb.org/jargon/html/G/grok.html) is because I'm a complete newbie to RoR, and the other part of it is because the **link_to** method has 4 distinct signatures that you can call it by.




After [some searching around](https://www.google.com/search?q=ruby%20on%20rails%20bootstrap%20link_to%20icon) I found a couple of resources on [Stack Overflow](http://stackoverflow.com/) which looked promising:






	
  * [link_to in helper with block](http://stackoverflow.com/questions/11317067/link-to-in-helper-with-block)


	
  * [Using link_to with embedded HTML](http://stackoverflow.com/questions/9401942/using-link-to-with-embedded-html)

	
  * [Best way to use Twitter Bootstrap Icons as Links in Ruby on Rails 3?](http://stackoverflow.com/questions/10764862/best-way-to-use-twitter-bootstrap-icons-as-links-in-ruby-on-rails-3)


However, none of those results were quite _exactly_ what I was looking for. They did provide some useful insight into solving the problem though.


# Solution


Here's the code:

https://gist.github.com/5497304


# Explanation


If my understanding is correct, then this approach implements the third link_to method signature: **link_to(options = {}, html_options = {}) do **

The **options** parameter we give here is a hash which is passed to the [url_for](http://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-url_for) method, and finally to the [Route Module](http://api.rubyonrails.org/classes/ActionDispatch/Routing.html). It ends up returning a URL string in the form of _http://yoursite/**pages/new**_

The **html_options** parameter describes the attributes (other than **href**) which we desire present in the generated anchor. In this example we are describing an anchor with two classes: **btn** and **btn-small**. You could add additional symbols to the hash just as easily: **{:class => 'btn btn-small', :id => 'new-page-button', :title => 'Create A New Page'}**

Finally, the way we're calling link_to requires that we pass it a block to use as the generated link body (or in our case, icon). So we escape from the ERB sequence for a moment, enter the HTML which Boostrap turns into an icon, and then close the block.
