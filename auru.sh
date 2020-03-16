#!/bin/bash

AUR_PATH="/home/$USER/AUR"
PREFIX="$AUR_PATH/"
PREFIX_LEN=${#PREFIX}


# TODO check if the folder aur exists

function user_says_no_to_update() {
	if ! [ -f "./.aur_tbu" ]; then
		touch .aur_tbu
	fi
}


function user_says_yes_to_update() {
        if [ -f "./.aur_tbu" ]; then
		rm .aur_tbu
		git pull
	fi
	makepkg -si
}


for folder in $AUR_PATH/*/ ; do
	cd $folder
	git_output=$(git pull)
	sw_name=${folder:$PREFIX_LEN:-1}
	if [ "$git_output" == "Already up to date." ] && ! [ -f "./.aur_tbu" ]  ; then
		echo "$sw_name is up-to-date"
	else
		echo "$sw_name is not up-to-date"
		read -p "Do you wish to upgrade '$sw_name'? " yn
		case $yn in
			[Yy]* ) users_says_yes_to_update;;
			[Nn]* ) user_says_no_to_update;;
			* ) user_says_no_to_update; echo "$sw_name: upgrade aborted"
		esac
	fi
	cd ..
done
