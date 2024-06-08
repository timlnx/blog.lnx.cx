---
author: al
date: 2014-11-04 16:31:22+00:00
layout: post
title: Repoquery for mock
categories:
- Fedora
tags:
- packaging
- zsh
---

I use [mock](http://fedoraproject.org/wiki/Projects/Mock) frequently when I am building packages for Fedora. Koji is great, but mock really shines when you are rapidly iterating over spec file changes. The `--no-clean` option keeps the chroot around so you don't have to download packages repeatedly and you can actually look around inside the chroot to see where a build is going wrong if you need to.

I also use [repoquery](http://yum.baseurl.org/wiki/RepoQuery) a lot to see what a package requires or provides. Knowing what a package requires or provides is especially helpful when you're doing builds. By default repoquery runs against the repos in `/etc/yum.repos.d`. Wouldn't it be nice if we could run repoquery against the repos set up in our mock configs?

It turns out that you can. Repoquery takes a `--repofrompath` argument that can be used to create an ad hoc repo to query. The only missing piece is reading the mock config, grabbing the repo URL, and formatting it.

I wrote a little Zsh function to do just that.

    
    <code class="prettyprint">#! /bin/zsh
    
    mock-repoquery() {
        local profile="$1"
        [ -f "$profile" ] || profile="/etc/mock/${1}.cfg"
    
        # Take all baseurls in a file and make them into an array
        # See Parameter Expansion Flags section of the zshexpn man page and
        # http://unix.stackexchange.com/a/29748
        local repo_urls
        repo_urls=("${(@f)$(sed -n -r 's/.*baseurl=(.*)(\\n|$)/\1/p' $profile | cut -d'\' -f1)}")
        local repo_args
        repo_args=()
        for ((i=1; i <= ${#repo_urls}; i++)); do
            repo_args+="--repofrompath=r${i},$repo_urls[i]"
            repo_args+="--repoid=r${i}"
        done 
        repoquery "${repo_args[@]}" "$@[2,-1]"
    }
    
    mock-repoquery "$@"
    </code>


Drop the above code into `~/.zfunc/mock-repoquery` and then add the following to `~/.zshrc`

    
    <code class="prettyprint">fpath=( ~/.zfunc "${fpath[@]}" )
    autoload -Uz mock-repoquery
    </code>


Then you can use `mock-repoquery` by passing a mock profile as the first argument. Any additional arguments will be forwarded to repoquery. For example:

    
    <code>$ mock-repoquery /etc/mock/fedora-20-x86_64.cfg --requires tig
    git
    libc.so.6(GLIBC_2.15)(64bit)
    libncursesw.so.5()(64bit)
    libtinfo.so.5()(64bit)
    rtld(GNU_HASH)
    </code>


Note that `mock-repoquery` will only work in Zsh due to my usage of Zsh parameter expansion. Converting this function to work in Bash is possible, but I use Zsh so I didn't bother. Patches will be accepted happily!
