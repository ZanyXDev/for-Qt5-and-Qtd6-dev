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
QT_VERSION="v5.15.10-lts-lgpl"
SRC_VOLUME_NAME="${QT_VERSION}-src-volume"
SDK_VOLUME_NAME="${QT_VERSION}-androidsdk-volume"
OPT_VOLUME_NAME="${QT_VERSION}-opt-volume"

docker pull bitnami/git:latest
docker pull bash:latest
docker pull ubuntu:22.04

echo -e "-----------------${blue}check exist and dowloads files from github.com${reset}---------------------------"

if ! [ -f qt5_git_clone.sh ]; then
  echo "File qt5_git_clone.sh ${red}does not exist${reset}. Now downloading..."
  download https://raw.githubusercontent.com/ZanyXDev/for-Qt5-and-Qtd6-dev/main/scripts/qt5_git_clone.sh qt5_git_clone.sh
  chmod +x qt5_git_clone.sh 
fi

docker run \
       -v $(pwd)/qt5_git_clone.sh:/root/qt5_git_clone.sh  \
	   -v  ${SRC_VOLUME_NAME}:/usr/local/src \
       -ti --rm --name git bitnami/git:latest /root/qt5_git_clone.sh ${QT_VERSION} "https://invent.kde.org/qt/qt/qt5.git" "/usr/local/src/qt5"

if ! [ -f openssl_git_clone.sh ]; then
  echo "File openssl_git_clone.sh ${red}does not exist${reset}. Now downloading..."
  download https://raw.githubusercontent.com/ZanyXDev/for-Qt5-and-Qtd6-dev/main/scripts/openssl_git_clone.sh openssl_git_clone.sh
  chmod +x openssl_git_clone.sh
fi       

docker run \
       -v $(pwd)/openssl_git_clone.sh:/root/openssl_git_clone.sh  \
	   -v  ${SRC_VOLUME_NAME}:/usr/local/src \
       -ti --rm --name git bitnami/git:latest /root/qt5_git_clone.sh "https://github.com/KDAB/android_openssl.git" "/usr/local/src/android_openssl"


