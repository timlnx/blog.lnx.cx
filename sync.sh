#!/bin/bash

cd dest
rsync --exclude '*~' --recursive -vz --progress -e 'ssh' * lnx.cx:/var/www/blog.lnx.cx/
