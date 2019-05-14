#!/bin/sh
expr $1 + 1 >/dev/null 2>&1
[ $? -eq 0 ] &&echo int||echo chars


