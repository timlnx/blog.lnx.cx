#!/bin/bash

cd dest
rsync --exclude '*~' --recursive -vz --progress -e 'ssh' * tbielawa@lnx.cx:/var/www/blog.lnx.cx/
