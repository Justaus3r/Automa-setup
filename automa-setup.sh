#!/usr/bin/env bash

# A script for personal use on arch-based live environment
#WARNING:Many things done in this script are  conventionally and systematically bad like updating like bare/partial updating(see https://wiki.archlinux.org/title/System_maintenance#Partial_upgrades_are_unsupported) Plus LOTSA DUPLICATIONS,unefficeincy,etc.use other than on live evironment is discouraged

# NEED MAJOR REFACTOR FOR ARG_PARSER FUNCTIONALITY,Kinda like :It's working and i dunno why + its not working and i dunno why

RED_COLOR='\033[0;31m'
GREEN_COLOR='\033[0;32m'
YELLOW_COLOR='\033[0;33m'
CYAN_COLOR='\033[0;36m'
COLOR_RESET='\e[0m'
PIP_DOWNLOAD_LINK="https://bootstrap.pypa.io/get-pip.py"
VSCODE_GIT_LINK="https://aur.archlinux.org/visual-studio-code-bin.git"
UPDATE_SYSTEM="sudo pacman -Sy"
PIP_CMD="python3 -m pip"
DEPENDENCIES=("wget" "git")
PYTHON_PACKAGES=("ptpython" "rich" "xonsh" "pygments" "prompt-toolkit" "ranger-fm" "whoogle-search")
QUTEBROWSER_CONF_BASEURL="https://gist.githubusercontent.com/Justaus3r/b6cf267fdb3432243897b93ecf6fe3f4/raw/68fd6bd62d35b4634b7bab86cd22038d287cb8ed/"
QUTEBROWSER_CONF_FILENAMES=("config.py" "returnytdislike.js" "yt_adblock.js" "ytretrowavetheme.js")
declare -A ARG_HASHTABLE=( ["editor"]="nvim" ) # neko's default editor zzz nvim
ARG_ARRAY=( ${@} )
ARG_ARRAY_COPY=$ARG_ARRAY
index_of_return_val=0
NVIM_CONF_PATH="$HOME/.config/nvim/"
QUTES_CONF_PATH="$HOME/.config/qutebrowser/"
print() {
    local string=$1
    local color=$2
    local no_escape=$3
    local escape_char='\n'

    if [[ $no_escape = "no_escape" ]];then
        escape_char=''
    fi
    
    if [[ $color = "red" ]];then
        printf "$RED_COLOR$string$COLOR_RESET$escape_char"
        elif [[ $color = "green" ]];then
        printf "$GREEN_COLOR$string$COLOR_RESET$escape_char"
        elif [[ $color = "yellow" ]];then
        printf "$YELLOW_COLOR$string$COLOR_RESET$escape_char"
        elif [[ $color = "cyan" ]];then
        printf "$CYAN_COLOR$string$COLOR_RESET$escape_char"
    else
        printf "$string$escape_char"
    fi
}

powise_hewp_onichan() {
    print "No hewp for you!,you are a dirty,horny and a slutty neko" "red"
    exit 0
}

stderr_print() {
    print "ERROR:$1" "red"
    if [[ $2 = "quit_after" ]];then
        exit -1
    fi
}

gen_index_of() {
    local to_search_str=$1
    local index=0
    # Same problem here,the ARG_ARRAY isn't getting modified dynamically so
    # we gotta manually update it
    ARG_ARRAY=${ARG_ARRAY_COPY[@]}
    for element in ${ARG_ARRAY[@]};do
        if [[ $element = $to_search_str ]];then
            index_of_return_val=$index
        fi
        index=$(($index+1))
    done
}

remove_element() {
    local first_element=$1
    local second_element=$2
    local el_to_remove_array=( $first_element $second_element )
    local idx=0
    for element in ${el_to_remove_array[@]};do
        for i in ${!ARG_ARRAY[@]};do
            if [[ ${ARG_ARRAY[i]} = $element ]];then
                unset "ARG_ARRAY[i]"
            fi
            idx=$(($idx+1))
        done
    done
}

#arg_array_formatter() {
#    # gotta reformat the array into --> <Args having a value> <single arguments>
#    local two_op_arg=''
#    for element in ${ARG_ARRAY[@]};do
#        if [[ $element = '-e' ]];then
#            two_op_arg=$element
#            break
#        elif [[ $element = '--editor' ]];then
#           two_op_arg=$element
#            break
#        fi
#   done
#  gen_index_of $two_op_arg
#    local param_arg=${ARG_ARRAY[$(($index_of_return_val+1))]}
#    remove_element $two_op_arg $param_arg 
#    local head_array=($two_op_arg $param_arg)
#    ARG_ARRAY=(${head_array[@]} ${ARG_ARRAY[@]})
#}

arg_parser() {
    # A FUCKIN BLOODY HELL THIS IS
    local current_arg=''
    local rm_next_el=false
    local param_arg=''
    for arg in ${ARG_ARRAY[@]};do
        # The ARG_ARRAY that is being modified with every arg being processed 
        # is not updating in the parent loop,dunno exactly why but maybe cuz in 
        # bash it doesn;t update the array dynamically and the one in the current loop
        # stack just doesn't update so we use this hack to check the parent loop and if the 
        # current element is equal to current element of child loop then it means that it was array was 
        # updated correctly,otherwise we update the parent argument(i.e $arg) to the modified current 
        # argument(i.e $arg_1)
       for arg_1 in ${ARG_ARRAY[@]};do
           if [[ $arg = $arg_1 ]];then
               break
           else
               arg=$arg_1
               break
           fi
       done
       if [[ ${#ARG_ARRAY[@]} -eq 0 ]];then
            break
        elif [[  $arg = "--help" || $arg = "--hewp" || $arg = "--hewpme" || $arg = "-h" ]];then
            current_arg='-h'
            powise_hewp_onichan
            elif [[ $arg = "--editor" || $arg = "-e" ]];then
           if [[ $arg = "--editor" ]];then
                gen_index_of "--editor"
                current_arg="--editor"
            elif [[ $arg = "-e" ]];then
                gen_index_of "-e"
                current_arg='-e'       
            fi   
            rm_next_el=true
            param_arg=${ARG_ARRAY[$(($index_of_return_val+1))]}
            if [[ ! -z $param_arg ]];then
                ARG_HASHTABLE["editor"]=$param_arg
            fi
        elif [[ $arg = '--kyaa' ]];then
            echo "KYAAAAAAAAAAAAA"
        elif [[ $arg = '--nyaa' ]];then
            echo "NYAAAAAAAAAAAAA"
       	elif [[ $arg = '--upgrade' || $arg = '-u' ]];then
       		UPDATE_SYSTEM="sudo pacman -Syu"
        else
            echo $arg
            print "Kyaaaaaaaaaa!,you dirty neko!,don't tease me" "red"
            exit -1
        fi
       	#gotta remove the args that have been processed from ARG_ARRAY
        if [[ $rm_next_el = true ]];then
            remove_element $arg $param_arg
        else
            remove_element $arg
        fi
        # modifying the copy array manually
        ARG_ARRAY_COPY=${ARG_ARRAY[@]}
  done
}

update_system() {
    print "Updating Available package list..." "green"
    $UPDATE_SYSTEM
    if [[ $? -ne 0 ]];then
        stderr_print "Couldn't update the package list\nResolve the error manually and run the script again." "quit_after"
    fi
}

check_dependencies() {
    print "Verifying dependencies.." "green"
    for dependency in ${DEPENDENCIES[@]};do
        if [[ ! -x "$(command -v $dependency)" ]];then
            stderr_print "$dependency is not installed" "quit_after"
        fi
    done
}

validate_n_install_pip() {
    $PIP_CMD 1> /dev/null
    if [[ $? -eq 0 ]];then
        return
    fi
    print "Pip not found,installing.." "red"
    wget $PIP_DOWNLOAD_LINK
    python3 get-pip.py
    rm get-pip.py
}

update_mirror_list() {
    sudo cp ../res/mirrorlist /etc/pacman.d/mirrorlist
}


install_pip_packages() {
    validate_n_install_pip
    for package in ${PYTHON_PACKAGES[@]};do
        python3 -m pip install $package
    done
}

sync_nvim_configs() {
    if [[ ! -d "./init.vim" ]];then  
        print "Cloning init.vim from gihtub.com/justaus3r/init.vim.." "cyan"
        git clone https://github.com/Justaus3r/init.vim.git 2>/dev/null
        if [[ $? -ne 0 ]];then
            stderr_print "An error occured while cloning init.vim from github.com/justaus3r/init.vim,resolve the error manually" "quit_after"  
        fi
    fi
    cd init.vim
    chmod +x install.sh
    ./install.sh
    cd ../
}


install_editor() {
    local retry_limit=0
    local _editor=$1
    if [[ $_editor = "vscode" ]];then
        if [[ -x "$(command -v code)" ]];then
            print "Vscode is installed!" "green"
            return
        fi
        git clone $VSCODE_GIT_LINK
        cd visual-studio-code-bin
        yes | makepkg -si
        if [[ $? -eq 0 ]];then
            cd ../ && rm -rf visual-studio-code-bin
        else
            if [[ $retry_limit -eq 0 ]];then
                stderr_print "An error occured!,Updating mirror-list"
                print "Retrying!" "yellow"
                retry_limit=1
                update_mirror_list
                sudo pacman -Syy
                download_n_install_shid
            else
                stderr_print "Unable to resolve error automatically!,please resolve it manually and run the script again" "quit_after"
            fi
        fi
    elif [[ $_editor = "nvim" || $_editor = "neovim" ]];then
        if [[ ! -x $(command -v nvim) ]];then
            print "Neovim not found,installing.." "yellow"
            yes | sudo pacman -S neovim
        
             if [[ $? -ne 0 ]];then
                 stderr_print "An error occured while installing package 'neovim',please install it manually and run the script again to resume!" "quit_after"
             fi
        fi
    else
        print "WARNING:The package is not in default editors list,enter package name(optional,s to skip):" "yellow" "no_escape"
        read package_name
        if [[ $package_name = 's' || $package_name = 'S' ]];then
            print "Skipping!" "green"
            return 0
        fi
        yes | sudo pacman -S $package_name
        if [[ $? -ne 0 ]];then
            stderr_print "An error occured while installing '$package_name'"  
        fi
    fi
    if [[ -d $NVIM_CONF_PATH ]];then
        print "Neovim seems to be configured!" "cyan"
        return 0
    fi
    sync_nvim_configs
}

installnsync_qutebrowser() {
    if [[ ! -x $(command -v qutebrowser) ]];then
        yes | sudo pacman -S qutebrowser
        if [[ $? -ne 0 ]];then
            stderr_print "An error occured while installing qutebrowser,please install it manually and run the script again" "quit_after"
        fi
	fi
	if [[ ! -d $QUTES_CONF_PATH ]];then
        for file in ${QUTEBROWSER_CONF_FILENAMES[@]};do
            wget $QUTEBROWSER_CONF_BASEURL$file
        done
        print "Qute-browser will be started for a moment to let it do its initialization,which btw am too lazy to do my self..." "cyan"
        qutebrowser &
        sleep 3
        pkill qutebrowser
        cp ${QUTEBROWSER_CONF_FILENAMES[0]} $QUTES_CONF_PATH
        cp  ${QUTEBROWSER_CONF_FILENAMES[1]} ${QUTEBROWSER_CONF_FILENAMES[2]} ${QUTEBROWSER_CONF_FILENAMES[3]} $QUTES_CONF_PATH/greasemonkey  
        if [[ $? -ne 0 ]];then
            stderr_print "Error while copying config" "quit_after"
        fi
	fi    
}

ayi_neko_chan() {
    print "Ayi!,so you have ~~c~u~m~b~a~k~a~~(i mean come back).." "cyan"
    print "You go nyaaa and lemme do stuff!." "yellow"
}

ayi_neko_chan
arg_parser
check_dependencies
update_system
install_pip_packages
install_editor ${ARG_HASHTABLE['editor']}
installnsync_qutebrowser
