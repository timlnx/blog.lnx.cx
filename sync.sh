#!/bin/bash

rsync -vz --progress -e 'ssh -l root' dest/ lnx.cx:/var/www/blog.lnx.cx/
