#!/bin/bash

AUR_PATH="/home/$USER/AUR"
SUDO_AUR_PATH="/home/$SUDO_USER/AUR"

bold=$(tput bold)
normal=$(tput sgr0)
DEFAULT_COLOR="\e[39m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
LIGHT_CYAN="\e[96m"


if ! [ $(id -u) = 0 ]; then
	echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} The installation script must be run as 'root'"
	exit 1
fi

cp auru.sh /usr/bin/auru

# Create AUR folder
if ! [ -d "$SUDO_AUR_PATH" ] ; then
	sudo -u $SUDO_USER mkdir $SUDO_AUR_PATH
fi


# TODO edit cp
# Create auru folder
if ! [ -d "$SUDO_AUR_PATH/auru" ] ; then
	sudo -u $SUDO_USER cp -r ../auru $SUDO_AUR_PATH
fi


# Create auru manual entry
if ! [ -d "/usr/local/share/man/man8" ] ; then
	mkdir /usr/local/share/man/man8
fi
cp man_auru /usr/local/share/man/man8/auru.8
gzip /usr/local/share/man/man8/auru.8
mandb
