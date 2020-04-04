#!/bin/bash

AUR_PATH="/home/$USER/AUR"
SUDO_AUR_PATH="/home/$SUDO_USER/AUR/"
PREFIX="$AUR_PATH/"
PREFIX_LEN=${#PREFIX}

bold=$(tput bold)
normal=$(tput sgr0)
DEFAULT_COLOR="\e[39m"
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
LIGHT_CYAN="\e[96m"


# TODO check if the folder aur exists

function user_says_no_to_update() {
	if ! [ -f "./.aur_tbu" ]; then
		touch .aur_tbu
	fi
}


function user_says_yes_to_update() {
	makepkg -si
	if [ -f "./.aur_tbu" ]; then
		rm .aur_tbu
	fi
}



function user_says_yes_to_update_auru() {
	if [ -f "./.aur_tbu" ]; then
		rm .aur_tbu
	fi
	sh install.sh
}


function update_auru() {
	cd ${SUDO_AUR_PATH}auru
	git_output=$(sudo -u $SUDO_USER git pull)
	if [ "$git_output" == "Already up to date." ] && ! [ -f "./.aur_tbu" ]  ; then
		echo -e "${GREEN}${bold}auru${normal}${DEFAULT_COLOR} is up-to-date"
	else
		echo -e "${YELLOW}${bold}auru${normal}${DEFAULT_COLOR} is not up-to-date"
		read -p "Do you wish to upgrade 'auru'? " yn
		case $yn in
			[Yy]* ) user_says_yes_to_update_auru;;
			[Nn]* ) user_says_no_to_update;;
			* ) user_says_no_to_update; echo "${RED}${bold}auru:${normal}${DEFAULT_COLOR} upgrade aborted"
		esac
	fi
}



function update_package() {
	if [ "$1" == "auru" ] ; then
		echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} This action must be executed as 'root'"
		exit 1
	fi
	if [ -d "$AUR_PATH/$1" ] ; then
		cd $AUR_PATH/$1
		if ! [ -f ".auruignore" ] ; then
			git_output=$(git pull)
			if [ "$git_output" == "Already up to date." ] && ! [ -f "./.aur_tbu" ]  ; then
				echo -e "${GREEN}${bold}$1${normal}${DEFAULT_COLOR} is up-to-date"
			else
				echo -e "${YELLOW}${bold}$1${normal}${DEFAULT_COLOR} is not up-to-date"
				read -p "Do you wish to upgrade '$1'? " yn
				case $yn in
					[Yy]* ) user_says_yes_to_update;;
					[Nn]* ) user_says_no_to_update;;
					* ) user_says_no_to_update; echo "${RED}${bold}$1:${normal}${DEFAULT_COLOR} upgrade aborted"
				esac
			fi
		else
			echo -e "${RED}${bold}$1:${normal}${DEFAULT_COLOR} ignored"
		fi
	else
		echo -e "${RED}${bold}ERROR:${normal}${DEFAULT_COLOR} '$1' not installed"
	fi
}



function check_for_updates() {
	if [ $(id -u) = 0 ] && [[ "$1" == "auru" ]] ; then
		update_auru
		exit 0
	fi
	if [ $(id -u) = 0 ]; then
		echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} This action must NOT be executed as 'root'"
		exit 1
	fi
	if [ $(find $AUR_PATH -mindepth 1 -maxdepth 1 -type d | wc -l) = 0 ] ; then
		echo -e "${YELLOW}${bold}No repository installed${normal}${DEFAULT_COLOR}"
		exit 0
	fi
	if ! [ -z "$1" ]; then
		update_package "$1"
		exit 0
	fi

	for folder in $AUR_PATH/*/ ; do
		cd $folder
		sw_name=${folder:$PREFIX_LEN:-1}
		if ! [ -f ".auruignore" ] ; then
			git_output=$(git pull)
			if [ "$git_output" == "Already up to date." ] && ! [ -f "./.aur_tbu" ]  ; then
				echo -e "${GREEN}${bold}$sw_name${normal}${DEFAULT_COLOR} is up-to-date"
			else
				if ! [ "$sw_name" == "auru" ] ; then
					echo -e "${YELLOW}${bold}$sw_name${normal}${DEFAULT_COLOR} is not up-to-date"
					read -p "Do you wish to upgrade '$sw_name'? " yn
					case $yn in
						[Yy]* ) user_says_yes_to_update;;
						[Nn]* ) user_says_no_to_update;;
						* ) user_says_no_to_update; echo "${RED}${bold}$sw_name:${normal}${DEFAULT_COLOR} upgrade aborted"
					esac
				else
					touch .aur_tbu
					echo -e "${YELLOW}${bold}$sw_name${normal}${DEFAULT_COLOR} is not up-to-date. Run '${bold}sudo auru -U auru${normal}' to update"
				fi
			fi
		else
			echo -e "${RED}${bold}$sw_name:${normal}${DEFAULT_COLOR} ignored"
		fi
		cd ..
	done
}



function list_packages() {
	if [ $(id -u) = 0 ]; then
		echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} This action must NOT be executed as 'root'"
		exit 1
	fi
	for folder in $AUR_PATH/*/ ; do
		cd $folder
		if [ -f "PKGBUILD" ] ; then
			pkg_version=$(sed -n -e '/pkgver=/ s/.*\= *//p' PKGBUILD | head -n 1)
			pkg_rel=$(sed -n -e '/pkgrel=/ s/.*\= *//p' PKGBUILD | head -n 1)
			sw_name=${folder:$PREFIX_LEN:-1}
			if ! [ -f ".auruignore" ] ; then
				echo -e "${bold}$sw_name${GREEN} $pkg_version-$pkg_rel${normal}${DEFAULT_COLOR}"
			else
				echo -e "${bold}${RED}$sw_name $pkg_version-$pkg_rel${normal}${DEFAULT_COLOR}: not installed"
			fi
		fi
	done
}



function get_package() {
	if [ $(id -u) = 0 ]; then
		echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} This action must NOT be executed as 'root'"
		exit 1
	fi
	if [ -z "$1" ]; then
		echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} missing argument"
		exit 1
	fi
	regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
	if [[ $1  =~ $regex ]] ; then 
    		sw_name=$(echo $1 | sed -e 's/.*\/\(.*\).git.*/\1/')
		exists=$(git ls-remote -h $1)
		if [[ "$exists" != "" ]] ; then
 			read -p "Do you wish to download and install '$sw_name'? " yn
 			case $yn in
 				[Yy]* ) install_package "$1" "$sw_name";;
 				[Nn]* ) echo "$sw_name: installation aborted";;
				* ) echo "$sw_name: installation aborted"
			esac
		else
			echo "ERROR: '$1' repository not found"
			exit 1
		fi
	else
		exists=$(git ls-remote -h https://aur.archlinux.org/$1.git)
		if [[ "$exists" != "" ]] ; then
			read -p "Do you wish to download and install '$1'? " yn
 			case $yn in
				[Yy]* ) install_package "https://aur.archlinux.org/$1.git" "$1";;
				[Nn]* ) echo "$1: installation aborted";;
				* ) echo "$1: installation aborted"
			esac
		else    
			echo "ERROR: '$1' repository not found"
			exit 1
		fi    		
	fi
}


function install_package() {
	cd $AUR_PATH
	git clone $1
	cd ./$2
	makepkg -si
}



function build_package() {
	if [ $(id -u) = 0 ]; then
		echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} This action must NOT be executed as 'root'"
		exit 1
	fi
	if [ -z "$1" ]; then
		echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} missing argument"
		exit 1
	fi
	if [ "$1" == "auru" ] ; then
		echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} 'auru' is not an AUR package"
		exit 1
	fi
	cd $AUR_PATH/$1
	makepkg -si
	if [ -f ".auruignore" ] ; then
		rm .auruignore
	fi
}



function remove_package() {
	if ! [ $(id -u) = 0 ]; then
		echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} This action must be executed as 'root'"
		exit 1
	fi
	if [ -z "$1" ]; then
		echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} missing argument"
		exit 1
	fi
	if [ "$1" == "auru" ] ; then
		echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} 'auru' is not an AUR package"
		exit 1
	fi
	path="$SUDO_AUR_PATH$1"
	echo $path
	if ! [ -d $path ] ; then
		echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} '$1' is not installed"
		exit 1
	fi
	cd $path
	pkg_name=$(sed -n -e '/pkgname=/ s/.*\= *//p' PKGBUILD | head -n 1)
	pacman -R $pkg_name

	read -p "Do you wish to delete also the local git repository of '$1'? " yn
	case $yn in
		[Yy]* ) cd .. ; rm -fr ./$1 ;;
		[Nn]* ) sudo -u $SUDO_USER touch .auruignore ; exit 0 ;;
		* ) sudo -u $SUDO_USER touch .auruignore ; exit 0
	esac
}


function get_help() {
	echo -e "usage:\t auru <operation> [...]"
	echo -e "operations:"
	echo -e "\tauru {-h --help}"
	echo -e "\tauru {-B --build} <package>"
	echo -e "\tauru {-Q --query}"
	echo -e "\tauru {-R --remove} <package>"
	echo -e "\tauru {-S --sync} <package | repository link>"
	echo -e "\tauru {-U --upgrade} <package>"
	echo -e "\tauru {-V --version}"
}


function get_software_info() {
	echo -e "\n--------------------------------------------------------------------------------------------------\n"


echo -e "${LIGHT_CYAN}\t  .--.  .-. .-.,---.  .-. .-." 
echo -e "\t / /\ \ | | | || .-.\ | | | |" 
echo -e "\t/ /__\ \| | | || \`-'/ | | | |" 
echo -e "\t|  __  || | | ||   (  | | | |" 
echo -e "\t| |  |)|| \`-')|| |\ \ | \`-')|" 
echo -e "\t|_|  (_)\`---(_)|_| \)\ \`---(_)" 
echo -e "\t                   (__)      "
echo -e "\n${DEFAULT_COLOR}"

	echo -e "\tauru v.0.5.2"
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



if ! [ -f "/etc/arch-release" ] ; then
	echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} this Linux distribution is not Arch Based"
	exit 1
fi
if [ -d "$AUR_PATH" ] || [ -d "$SUDO_AUR_PATH" ] ; then
	operation=$1
	case $operation in
		-B ) build_package "$2";;
		--build ) build_package "$2";;
		-Q ) list_packages;;
		--query ) list_packages;;
		-R ) remove_package "$2";;
		--remove ) remove_package "$2";;
		-U ) check_for_updates "$2";;
		--upgrade ) check_for_updates "$2";;
		-S ) get_package "$2";;
		--sync ) get_package "$2";;
		-V ) get_software_info;;
		--version ) get_software_info;;
		* ) get_help
	esac
else
	echo -e "${bold}${RED}ERROR:${DEFAULT_COLOR}${normal} '~/AUR' not found"
	exit 1
fi