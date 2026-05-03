#!/bin/bash

cd _site
rsync --exclude '*~' --recursive -vz --progress -e 'ssh' * tbielawa@lnx.cx:/var/www/blog.lnx.cx/
