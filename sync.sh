#!/bin/bash

rsync -avz --progress -e 'ssh -p 2222 -l root' dest/ lnx.cx:/var/www/blog.lnx.cx/
