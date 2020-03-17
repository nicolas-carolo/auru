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


function check_for_updates() {
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
}


function get_help() {
	echo -e "usage:\t auru <operation>"
	echo -e "operations"
	echo -e "\tauru {-h --help}"
	echo -e "\tauru {-U --upgrade}"
	echo -e "\tauru {-V --version}"
}


function get_software_info() {
	echo -e "\n--------------------------------------------------------------------------------------------------\n"
	echo -e "\tauru v.0.1.0"
	echo -e "\tCopyright © 2020, Nicolas Carolo. All rights reserved."

	echo -e "\tRedistribution and use in source and binary forms, with or without modification,"
	echo -e "\tare permitted provided that the following conditions are met:"

    	echo -e "\t\t1. Redistributions of source code must retain the above copyright notice,"
	echo -e "\t\t\tthis list of conditions, and the following disclaimer."

    	echo -e "\t\t2. Redistributions in binary form must reproduce the above copyright notice,"
	echo -e "\t\t\tthis list of conditions, and the following disclaimer in the"
	echo -e "\t\t\tdocumentation and/or other materials provided with the distribution."

    	echo -e "\t\t3. Neither the name of the author of this software nor the names of contributors"
	echo -e "\t\t\tto this software may be used to endorse or promote products derived"
	echo -e "\t\t\tfrom this software without specific prior written consent."

	echo -e "\tTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND"
	echo -e "\tANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED"
	echo -e "\tWARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED."
	echo -e "\tIN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,"
	echo -e "\tINDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT"
	echo -e "\tNOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,"
	echo -e "\tOR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,"
	echo -e "\tWHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)"
	echo -e "\tARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE"
	echo -e "\tPOSSIBILITY OF SUCH DAMAGE\n"
	echo "--------------------------------------------------------------------------------------------------"
}


operation=$1
case $operation in
	-U ) check_for_updates;;
	--upgrade ) check_for_updates;;
	-V ) get_software_info;;
	--version ) get_software_info;;
	* ) get_help 
esac
