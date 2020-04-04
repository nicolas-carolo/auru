#!/bin/bash

AUR_PATH="/home/$USER/AUR"
SUDO_AUR_PATH="/home/$SUDO_USER/AUR"

bold=$(tput bold)
normal=$(tput sgr0)
DEFAULT_COLOR="\e[39m"
RED="\e[31m"


# Check sudo
if ! [ $(id -u) = 0 ]; then
	echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} The installation script must be run as 'root'"
	exit 1
fi

# Check Arch
if ! [ -f "/etc/arch-release" ] ; then
	echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} this Linux distribution is not Arch Based"
	exit 1
fi

# Check dependencies
which_output=$(which git)
if ! [ "$which_output" == "/usr/bin/git" ] ; then
	echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} git not installed. Install git for using auru"
	exit 1
fi

echo "Running the installer..."

# Copy auru in usr/bin
cp auru.sh /usr/bin/auru

# Create AUR folder
if ! [ -d "$SUDO_AUR_PATH" ] ; then
	sudo -u $SUDO_USER mkdir $SUDO_AUR_PATH
fi


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
