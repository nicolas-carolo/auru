#!/bin/bash

AUR_PATH="/home/$USER/AUR"


# TODO check if the folder aur exists

for folder in $AUR_PATH/*/ ; do
	cd $folder
	git_output=$(git pull)
	if [ "$git_output" == "Already up to date." ] ; then
		echo "${folder::-1} is up-to-date"
	else
		echo "${folder::-1} is not up-to-date"
		read -p "Do you wish to upgrade '$folder'? " yn
		case $yn in
			[Yy]* ) makepkg -si;;
			[Nn]* ) ;;
			* ) echo "${folder::-1}: upgrade aborted"
		esac
	fi
	cd ..
done
