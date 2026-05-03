#!/bin/bash

m=$(umask)
bundle exec jekyll clean
umask 0002
bundle exec jekyll build
umask ${m}
