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
QT_VERSION="v5.15.10-lts-lgpl"
SRC_VOLUME_NAME="${QT_VERSION}-src-volume"
SDK_VOLUME_NAME="${QT_VERSION}-android-sdk-volume"
QT5_OPT_VOLUME_NAME="${QT_VERSION}-opt-volume"
TOOLCHAIN_IMAGE_NAME="zanyxdev/qt5-toolchain:${QT_VERSION}" 
DEBUG_MODE=y

docker pull bitnami/git:latest
docker pull bash:latest
docker pull ubuntu:22.04
docker pull eclipse-temurin:17 

echo -e "-----------------${blue}check exist and dowloads files from github.com${reset}---------------------------"

download https://raw.githubusercontent.com/ZanyXDev/for-Qt5-and-Qtd6-dev/main/scripts/qt5_git_clone.sh qt5_git_clone.sh
chmod +x qt5_git_clone.sh 

download https://raw.githubusercontent.com/ZanyXDev/for-Qt5-and-Qtd6-dev/main/scripts/openssl_git_clone.sh openssl_git_clone.sh
chmod +x openssl_git_clone.sh

download https://raw.githubusercontent.com/ZanyXDev/for-Qt5-and-Qtd6-dev/main/scripts/get_androidsdk.sh get_androidsdk.sh
chmod +x get_androidsdk.sh

download https://raw.githubusercontent.com/ZanyXDev/for-Qt5-and-Qtd6-dev/main/scripts/build_qt5_amd64.sh build_qt5_amd64.sh
chmod +x build_qt5_amd64.sh 

#-------------------------------------------------------------------------------
docker run \
       -v $(pwd)/qt5_git_clone.sh:/root/qt5_git_clone.sh  \
	   -v  ${SRC_VOLUME_NAME}:/usr/local/src \
       -ti --rm --name git bitnami/git:latest /root/qt5_git_clone.sh ${QT_VERSION} "https://invent.kde.org/qt/qt/qt5.git" "/usr/local/src/qt5"     

docker run \
       -v $(pwd)/openssl_git_clone.sh:/root/openssl_git_clone.sh  \
	   -v ${SDK_VOLUME_NAME}:/opt/android-sdk \
       -ti --rm --name git bitnami/git:latest /root/openssl_git_clone.sh "https://github.com/KDAB/android_openssl.git" "/opt/android-sdk/android_openssl"

echo -e "-----------------${blue}check Docker image [${TOOLCHAIN_IMAGE_NAME}]${reset}---------------------------"

if docker image inspect $TOOLCHAIN_IMAGE_NAME >/dev/null 2>&1; then
    echo -e "Image ${green} ${TOOLCHAIN_IMAGE_NAME} exists local, update.${reset}"
    #docker pull ${TOOLCHAIN_IMAGE_NAME}
else
    echo -e "Image ${green} ${TOOLCHAIN_IMAGE_NAME} ${red}don't exists local, ${green}build.${reset}"
    if [ -d ../toolchain ]; then
        echo -e "${green}Directory exists.${reset}"
        else mkdir ../toolchain
    fi
    cd ../toolchain
    
    download https://raw.githubusercontent.com/ZanyXDev/for-Qt5-and-Qtd6-dev/main/toolchain/Dockerfile Dockerfile    
    
    docker  build \
	    --build-arg="QT_VERSION=5.15.10" \
        --build-arg="LANG=ru-RU.UTF-8" \
	    --build-arg="TZ=Europe/Moscow" \
	    --platform=linux/amd64 \
	    --tag=${TOOLCHAIN_IMAGE_NAME} .
	cd ../    
fi

echo -e "${green}Update android-sdk tools [minimum images] ${reset}"      
 
docker run \
	  -v ${SDK_VOLUME_NAME}:/opt/android-sdk \
	  -v ${SRC_VOLUME_NAME}:/usr/local/src \
	  -v $(pwd)/get_androidsdk.sh:/root/get_androidsdk.sh  \
      -ti --rm ${TOOLCHAIN_IMAGE_NAME} /root/get_androidsdk.sh $(id -u ${USER}) $(id -g ${USER})

echo -e "-----------------${green} Build QT5 $${QT_VERSION} from source amd64-target ${reset}---------------------------"

docker run \
	  -v ${SDK_VOLUME_NAME}:/opt/android-sdk \
	  -v ${QT5_OPT_VOLUME_NAME}:/opt/Qt \
	  -v ${SRC_VOLUME_NAME}:/usr/local/src:ro \
	  -v $(pwd)/build_qt5_amd64.sh:/root/build_qt5_amd64.sh  \
      -ti --rm ${TOOLCHAIN_IMAGE_NAME} /root/build_qt5_amd64.sh "5.15.10-amd64-lts-lgpl" $(id -u ${USER}) $(id -g ${USER}) ${DEBUG_MODE}

#Troubleshooting
#Enabling the logging categories under qt.qpa is a good idea in general. This will show some debug prints both from eglfs and the input handlers.
#export QT_LOGGING_RULES=qt.qpa.*=true


