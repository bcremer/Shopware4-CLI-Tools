#!/bin/bash

# Variable declaration
BASE="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VERSION="1.0"
HEADLINE="# CLI Tools v${VERSION}"
TMPDIR="${BASEDIR}/.tmp"

# Text color variables
txtred='\033[0;31m'       # red
txtgry='\033[1;30m'       # grey
txtgrn='\033[0;32m'       # green
txtylw='\033[0;33m'       # yellow
txtblu='\033[0;34m'       # blue
txtpur='\033[0;35m'       # purple
txtcyn='\033[0;36m'       # cyan
txtwht='\033[0;37m'       # white
bldred='\033[1;31m'       # red    - Bold
bldgrn='\033[1;32m'       # green
bldylw='\033[1;33m'       # yellow
bldblu='\033[1;34m'       # blue
bldpur='\033[1;35m'       # purple
bldcyn='\033[1;36m'       # cyan
bldwht='\033[1;37m'       # white
txtund=$(tput sgr 0 1)  # Underline
txtbld=$(tput bold)     # Bold
txtrst='\033[0m'          # Text reset

cfg_parser()
{
    ini="$(<$1)"                # read the file
    ini="${ini//[/\[}"          # escape [
    ini="${ini//]/\]}"          # escape ]
    IFS=$'\n' && ini=( ${ini} ) # convert to line-array
    ini=( ${ini[*]//;*/} )      # remove comments with ;
    ini=( ${ini[*]/\    =/=} )  # remove tabs before =
    ini=( ${ini[*]/=\   /=} )   # remove tabs be =
    ini=( ${ini[*]/\ =\ /=} )   # remove anything with a space around =
    ini=( ${ini[*]/#\\[/\}$'\n'cfg.section.} ) # set section prefix
    ini=( ${ini[*]/%\\]/ \(} )    # convert text2function (1)
    ini=( ${ini[*]/=/=\( } )    # convert item to array
    ini=( ${ini[*]/%/ \)} )     # close array parenthesis
    ini=( ${ini[*]/%\\ \)/ \\} ) # the multiline trick
    ini=( ${ini[*]/%\( \)/\(\) \{} ) # convert text2function (2)
    ini=( ${ini[*]/%\} \)/\}} ) # remove extra parenthesis
    ini[0]="" # remove first element
    ini[${#ini[*]} + 1]='}'    # add the last brace
    eval "$(echo "${ini[*]}")" # eval the result
}

output_header() {
    clear
    echo "     _                              "
    echo " ___| |_ ___ ___ _ _ _ ___ ___ ___  "
    echo "|_ -|   | . | . | | | | .'|  _| -_| "
    echo "|___|_|_|___|  _|_____|__,|_| |___| "
    echo "            |_|   ${HEADLINE}       "
    echo "____________________________________"
}

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps ax | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

create_headline() {
    echo
    echo -e "${txtcyn}${1}${txtrst}"
}
create_info_headline() {
    echo
    echo -e "${bldylw}${1}${txtrst}"
}

create_error() {
    echo
    echo -e "${bldred}[!] ${1}${txtrst}"
}

create_tmp() {
    if [ ! -d ${TMPDIR} ]; then
        mkdir ${TMPDIR}
        chmod -R 777 ${TMPDIR}
    fi
}
remove_tmp() {
    rm -rf ${TMPDIR}/*
}

parse_options() {
    CONFIG_FILE="${BASEDIR}/.sw4-cli-tools/config.ini"
    OPERATION=""

    while getopts "c:idk" OPTION
    do
        case $OPTION in
            c)
                CONFIG_FILE=$OPTARG
                ;;
            i)
                OPERATION=1
                ;;
            d)
                OPERATION=4
                ;;
            k)
                OPERATION=2
                ;;
        esac
    done

    # Check if config.ini exists...
    if [ ! -f "$CONFIG_FILE" ]; then
        echo
        echo -e "${bldred}[!] config file at $CONFIG_FILE doesn't exist. ${txtrst}"

        exit 1
    fi
}
