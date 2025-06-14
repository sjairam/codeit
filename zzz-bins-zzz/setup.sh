#!/bin/bash

# AWS variables
AWS_PROFILE=default
AWS_REGION=us-east-2

# project variables
PROJECT_NAME=aws-docker-github-kubernetes
WEBSITE_PORT=3000


error() { echo -e " $1 "; }
log()   { echo -e " $1 "; }      # $1 uppercase background white
warn()  { echo -e " $1 "; }

info() {
  printf "\r\033[00;35m$1\033[0m\n"
}

success() {
  printf "\r\033[00;32m$1\033[0m\n"
}

fail() {
  printf "\r\033[0;31m$1\033[0m\n"
}

#warn()  { echo -e "\e[48;5;202m ${1^^} \e[0m ${@:2}" >&2; } # $1 uppercase background orange
#error() { echo -e "\e[48;5;196m ${1^^} \e[0m ${@:2}" >&2; } # $1 uppercase background red

under() {
    local arg=$1
    #shift
    echo -e " ${arg} "
    echo
}

usage() {
    under usage 'call the Makefile directly: make dev
      or invoke this file directly: ./make.sh dev'
}
###############
## DEFAULT APP
###############
installAPP(){
   # t stores $1 argument passed to installAPP
    t=$1
    if [[ -z $(brew list | grep $1) ]]
    then
        if [[ -z $(which $1 ) ]]
        then
            info " ----> installing $1 " | tee -a ~/install.log
            brew install --cask $1
        else
            info " ==>> $1  already installed ! " | tee -a ~/install.log
        fi
    fi
}
####################
## DEFAULT TOOLS
####################
installTOOLS(){
   # t stores $1 argument passed to installAPP
    t=$1
  
    if [[ -z $(which $1 ) ]]
    then
        info " ----> installing $1 " | tee -a ~/install.log
        brew install $1 | tee -a ~/install.log
    else
        warn " ==>> $1  already installed ! " | tee -a ~/install.log
    fi

}

############
## MINKUBE 
############
installMINIKUBE () {
    if [[ -z $(which hyperkit) ]]
    then
        echo ' ----> installing hyperkit ' | tee -a ~/install.log
        brew install hyperkit
    else
        if [[ -z $(which minikube) ]]
        then
            echo ' ----> installing minkube ' | tee -a ~/install.log
            brew install minikube
        else
            log " --> minikube already installed." | tee -a ~/install.log
        fi
    fi
}

installBREW () {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

installFOR () {

    TOOLS_LIST="$dir/toolList.txt"
    for tools in `more ${TOOLS_LIST}`
    do
        sleep 2
        installTOOLS $tools
    done | column -t
}

installAPPsFOR () {

    APPS_LIST="$dir/appList.txt"
    for app in `more ${APPS_LIST}`
    do
        sleep 2
        if [[ -z $(which $app ) ]]
        then
            info " ----> installing $1 " | tee -a ~/install.log
            brew install --cask $app       | tee -a ~/install.log
        else
            info " ==>> $app  already installed ! " | tee -a ~/install.log
        fi
    done | column -t
}


installs () {

    #installAPP adobe-acrobat-reader
    #installTOOLS aws-iam-authenticator
    #installTOOLS docker
    #installTOOLS eksctl
    #installTOOLS gh
    #installTOOLS jq
    #installTOOLS kubectl
    #installTOOLS helm
    #installTOOLS hyperkit
    #installTOOLS minikube
    #installTOOLS python@3.11
    #installTOOLS terraform  
    installFOR
    #installMINIKUBE
    
    #installAPP authy
    #installAPP drawio
    #installAPP firefox
    #installAPP github
    #installAPP handbrake
    #installAPP iterm2
    #installAPP keepassxc
    #installAPP postman
    #installAPP thonny
    #installAPP vlc
    #installAPP zoom
    installAPPsFOR
}

#########
## MAIN 
#########

clear

# the directory containing the script file
export dir="$(cd "$(dirname "$0")"; pwd)"

TOOL_LIST="$dir/toolList.txt"
APP_LIST="$dir/appList.txt"

sleep 2

cd "$dir"

sleep 2

printf "\r\033[00;35;1m 
        -- > Starting   \033[0m"

if [[ -z $(which brew) ]]
    then
        info ' ----> installing Homebrew ' | tee -a ~/install.log
        installBREW
    else
        echo  " ----> Commencing installs ! " | tee -a ~/install.log
        sleep 2
        installs
        printf "\r\033[00;35;1m -- > COMPLETE   \033[0m" | tee -a ~/install.log
fi