#!/bin/bash

# Create auru manual entry
if ! [ -d "/usr/local/share/man/man8" ] ; then
	mkdir /usr/local/share/man/man8
fi
cp man_auru /usr/local/share/man/man8/auru.8
gzip /usr/local/share/man/man8/auru.8
mandb
