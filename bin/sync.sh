#!/bin/bash
# SPDX-FileCopyrightText: 2024-2026 Tim Case <tim@lnx.cx>
# SPDX-License-Identifier: MIT

cd _site
rsync --exclude '*~' --recursive -vz --progress -e 'ssh' * tbielawa@lnx.cx:/var/www/blog.lnx.cx/
