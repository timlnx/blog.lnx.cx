#!/bin/bash
# SPDX-FileCopyrightText: 2026 Tim Case <tim@lnx.cx>
# SPDX-License-Identifier: MIT

m=$(umask)
bundle exec jekyll clean
umask 0002
bundle exec jekyll build
umask ${m}
