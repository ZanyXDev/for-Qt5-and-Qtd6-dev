#!/bin/bash
# Ansi color code variables
red="\e[0;91m"
blue="\e[0;94m"
expand_bg="\e[K"
blue_bg="\e[0;104m${expand_bg}"
red_bg="\e[0;101m${expand_bg}"
green_bg="\e[0;102m${expand_bg}"
green="\e[0;92m"
white="\e[0;97m"
uline="\e[4m"
reset="\e[0m"

#-------------------------------------------------------------------------------
function download {
    url=$1
    filename=$2

    if [ -x "$(which wget)" ] ; then
        wget -q $url -O $2
    elif [ -x "$(which curl)" ]; then
        curl -o $2 -sfL $url
    else
        echo "Could not find curl or wget, please install one." >&2
    fi
}
# to use in the script:
#download https://url /local/path/to/download

#-------------------------------------------------------------------------------
set -e;
clear
echo -e "------------------------${red}Docker pull images from hub.docker.com${reset}---------------------------"
TAG="5.15.10-lts-lgpl"

docker pull bitnami/git:latest
docker pull bash:latest
docker pull ubuntu:22.04

echo -e "-----------------${blue}check exist and dowload files from github.com${reset}---------------------------"

if ! [ -f qt5_git_clone.sh ]; then
  echo "File does not exist."
fi

