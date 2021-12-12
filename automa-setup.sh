#!/usr/bin/env bash

# A script for personal use on arch-based live environment
#WARNING:Many things done in this script are  terrible like updating like bare/partial updating(see https://wiki.archlinux.org/title/System_maintenance#Partial_upgrades_are_unsupported) ,unefficent,etc.use other than on live evironment is higly discouraged 


RED_COLOR='\033[0;31m'
GREEN_COLOR='\033[0;32m'
YELLOW_COLOR='\033[0;33m'
CYAN_COLOR='\033[0;36m'
COLOR_RESET='\e[0m'
PIP_DOWNLOAD_LINK="https://bootstrap.pypa.io/get-pip.py"
VSCODE_GIT_LINK="https://aur.archlinux.org/visual-studio-code-bin.git"
UPDATE_SYSTEM="sudo pacman -Sy" # should be usin "sudo pacman -Syu" as -Sy could break other packages but ima go with it anyway  
DEPENDENCIES=("wget" "git")
PIP_CMD="python3 -m pip"
PYTHON_PACKAGES=("ptpython" "rich" "xonsh" "pygments" "prompt-toolkit")

function print {
	local string=$1
	local color=$2
	if [ "$color" = "red" ];then
		printf "$RED_COLOR$string$COLOR_RESET\n"
	elif [ "$color" = "green" ];then
		printf "$GREEN_COLOR$string$COLOR_RESET\n"
	elif [ "$color" = "yellow" ];then
		printf "$YELLOW_COLOR$string$COLOR_RESET\n"
	elif [ "$color" = "cyan" ];then
		printf "$CYAN_COLOR$string$COLOR_RESET\n"
	else
		printf "$string\n"
	fi
}

function update_system {
	print "Updating Available package list..." "green"
	$UPDATE_SYSTEM
	if [ $? -ne 0 ];then
		print "ERROR:Couldn't update the package list" "red"
		print "Resolve the error manually and run the script again." "yellow"
		exit 
	fi

	print 
}

function check_dependencies { 
	print "Verifying dependencies.." "green"
	for dependency in ${DEPENDENCIES[@]};do
		if ! [ -x "$(command -v $dependency)" ];then
			print "ERROR:$dependency is not installed" "red"
			exit 
		fi
	done
}

function install_pip {
	$PIP_CMD 1> /dev/null
	if [ $? -eq 0 ];then
		return
	fi
	wget $PIP_DOWNLOAD_LINK
	python3 get-pip.py
	rm get-pip.py
}

function update_mirror_list {
	sudo cp ../res/mirrorlist /etc/pacman.d/mirrorlist
}

function download_n_install_shid {
	local retry_limit=0
	for ((i = 0; i < 5; i++ ));do
		python3 -m pip install ${PYTHON_PACKAGES[i]}
	done
	if [ -x "$(command -v code)" ];then
		return
	fi
	git clone $VSCODE_GIT_LINK
	cd visual-studio-code-bin
	yes | makepkg -si
	if [ $? -eq 0 ];then
		cd ../ && rm -rf visual-studio-code-bin
	else
		if [ $retry_limit -eq 0 ];then
			print "ERROR:An error occured!,Updating mirror-list" "red"
			print "Retrying!" "yellow"
			retry_limit=1
			update_mirror_list
			sudo pacman -Syy
			download_n_install_shid
		else
			print "ERROR:Unable to resolve error automatically!,please resolve it manually and run the script again" "red"
			exit
		fi	
	fi 	
}

function yo_mothafucka {
 	print "Ayi!,so you have cum baka(i mean come back).." "cyan"
	print "Wait and read some doujins while i do some bad shit here.." "yellow"
}

yo_mothafucka
check_dependencies
update_system
install_pip
download_n_install_shid
