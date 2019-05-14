#!/bin/sh
while true
do
	read -p "pls intput:" a
	expr $a + 0 >/dev/null 2>&1
	[ $? -eq 0 ] && echo int || echo chars
done
