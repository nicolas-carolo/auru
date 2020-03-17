#!/bin/bash

# Create auru manual entry
sudo cp man_auru /usr/local/share/man/man8/auru.8
sudo gzip /usr/local/share/man/man8/auru.8
sudo mandb
