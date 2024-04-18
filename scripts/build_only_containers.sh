#!/bin/bash
tput setab 2; reset; echo test

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
# check file exist
    if ! [ -f $2 ]; then  
        echo -e "File $2 does not exist. Now downloading..."  
        if [ -x "$(which wget)" ] ; then
            wget -q $url -O $2
        elif [ -x "$(which curl)" ]; then
            curl -o $2 -sfL $url
        else
            echo "Could not find curl or wget, please install one."
            exit 1
        fi
    fi 
}
# to use in the script:
#download https://url /local/path/to/download

#-------------------------------------------------------------------------------
set -e;
clear
echo -e "------------------------${red}Docker pull images from hub.docker.com${reset}---------------------------"
QT_VERSION="v5.15.13-lts-lgpl"
QT_VERSION_SHORT="5.15.13"

SRC_VOLUME_NAME="${QT_VERSION}-src-volume"
SDK_VOLUME_NAME="${QT_VERSION}-android-sdk-volume"
QT5_OPT_VOLUME_NAME="${QT_VERSION}-opt-volume"
#Том данных , чтобы данные могли сохраняться между компиляциями/сборками
CCACHE_VOLUME="${QT_VERSION}-ccache-volume"

TOOLCHAIN_IMAGE_NAME="zanyxdev/qt5-toolchain:${QT_VERSION}" 
QTCREATOR_IMAGE_NAME="zanyxdev/qt5-qtcreator:v13.0.0" 
QTCREATOR_URL="https://github.com/qt-creator/qt-creator/releases/download/v13.0.0/qtcreator-linux-x64-13.0.0.deb"

BASE_DIR=$(pwd)

docker pull bitnami/git:latest
docker pull ubuntu:22.04
docker pull eclipse-temurin:17 


    cd ${BASE_DIR} && cd ../toolchain
    echo -e "Image ${green} ${TOOLCHAIN_IMAGE_NAME} ${red}don't exists local, ${green}build.${reset}"
    echo docker  build \
	    --build-arg="QT_VERSION=${QT_VERSION_SHORT}" \
	    --build-arg="LANG=ru-RU.UTF-8" \
	    --build-arg="TZ=Europe/Moscow" \
	    --platform=linux/amd64 \
	    --tag=${TOOLCHAIN_IMAGE_NAME} .

    cd ${BASE_DIR} && cd ../gui

   [ -d "$HOME"/docker_dev_home ] && rm -R -f "$HOME"/docker_dev_home

    docker  build \
        --build-arg="QT_VERSION=${QT_VERSION_SHORT}" \
        --build-arg="LANG=ru-RU.UTF-8" \
        --build-arg="TZ=Europe/Moscow" \
        --build-arg="QTCREATOR_URL=${QTCREATOR_URL}" \
        --build-arg="USER_ID=$(id -u ${USER})"       \
        --build-arg="GROUP_ID=$(id -g ${USER})"       \
        --platform=linux/amd64 \
        --tag=${QTCREATOR_IMAGE_NAME} .

