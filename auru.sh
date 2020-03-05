#!/bin/bash

AUR_PATH="/home/$USER/AUR"
PREFIX="$AUR_PATH/"
PREFIX_LEN=${#PREFIX}


# TODO check if the folder aur exists

for folder in $AUR_PATH/*/ ; do
	cd $folder
	git_output=$(git pull)
	sw_name=${folder:$PREFIX_LEN:-1}
	if [ "$git_output" == "Already up to date." ] ; then
		echo "$sw_name is up-to-date"
	else
		echo "$sw_name is not up-to-date"
		read -p "Do you wish to upgrade '$folder'? " yn
		case $yn in
			[Yy]* ) makepkg -si;;
			[Nn]* ) ;;
			* ) echo "$sw_name: upgrade aborted"
		esac
	fi
	cd ..
done
