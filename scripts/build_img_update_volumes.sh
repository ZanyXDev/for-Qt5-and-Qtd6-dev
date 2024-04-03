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
QTCREATOR_IMAGE_NAME="zanyxdev/qt5-qtcreator:v12.0.2" 
QTCREATOR_URL="https://github.com/qt-creator/qt-creator/releases/download/v12.0.2/qtcreator-linux-x64-12.0.2.deb"

BASE_DIR=$(pwd)

docker pull bitnami/git:latest
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

download https://raw.githubusercontent.com/ZanyXDev/for-Qt5-and-Qtd6-dev/main/scripts/build_qt5_android.sh build_qt5_android.sh
chmod +x build_qt5_android.sh

download https://raw.githubusercontent.com/ZanyXDev/for-Qt5-and-Qtd6-dev/main/scripts/run_qtcreator_docker.sh run_qtcreator_docker.sh
chmod +x run_qtcreator_docker.sh

cd ${BASE_DIR} && cd ../
[[ -d toolchain ]] || mkdir toolchain    
[[ -d gui ]] || mkdir gui    
download https://raw.githubusercontent.com/ZanyXDev/for-Qt5-and-Qtd6-dev/main/toolchain/Dockerfile toolchain/Dockerfile    
download https://raw.githubusercontent.com/ZanyXDev/for-Qt5-and-Qtd6-dev/main/gui/Dockerfile gui/Dockerfile   
 
#-------------------------------------------------------------------------------
cd ${BASE_DIR}
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
    cd ${BASE_DIR} && cd ../toolchain
    echo -e "Image ${green} ${TOOLCHAIN_IMAGE_NAME} ${red}don't exists local, ${green}build.${reset}"
    docker  build \
	    --build-arg="QT_VERSION=${QT_VERSION_SHORT}" \
	    --build-arg="LANG=ru-RU.UTF-8" \
	    --build-arg="TZ=Europe/Moscow" \
	    --platform=linux/amd64 \
	    --tag=${TOOLCHAIN_IMAGE_NAME} .
     cd ${BASE_DIR}
fi

echo -e "${green}Update android-sdk tools [minimum images] ${reset}"       
docker run \
       --env "USER_ID=$(id -u ${USER})"       \
       --env "GROUP_ID=$(id -g ${USER})"       \
	  -v ${SDK_VOLUME_NAME}:/opt/android-sdk \
	  -v ${SRC_VOLUME_NAME}:/usr/local/src \
	  -v $(pwd)/get_androidsdk.sh:/root/get_androidsdk.sh  \
      -ti --rm ${TOOLCHAIN_IMAGE_NAME} /root/get_androidsdk.sh

echo -e "-----------------${green} Build QT5 ${QT_VERSION} from source amd64-target ${reset}---------------------------"

docker run \
       --env "QT_PATH=/opt/Qt/${QT_VERSION_SHORT}-amd64-lts-lgpl" \
       --env "USER_ID=$(id -u ${USER})"       \
       --env "GROUP_ID=$(id -g ${USER})" \
       --env "CCACHE_DIR=/ccache" \
      -v ${CCACHE_VOLUME}:/ccache \
      -v ${SDK_VOLUME_NAME}:/opt/android-sdk \
      -v ${QT5_OPT_VOLUME_NAME}:/opt/Qt \
      -v ${SRC_VOLUME_NAME}:/usr/local/src:ro \
      -v $(pwd)/build_qt5_amd64.sh:/root/build_qt5_amd64.sh  \
      -ti --rm ${TOOLCHAIN_IMAGE_NAME} /root/build_qt5_amd64.sh

 docker run \
       --env "QT_PATH=/opt/Qt/${QT_VERSION_SHORT}-android-lts-lgpl" \
       --env "USER_ID=$(id -u ${USER})"       \
       --env "GROUP_ID=$(id -g ${USER})"       \
       --env "CCACHE_DIR=/ccache" \
       -v ${SDK_VOLUME_NAME}:/opt/android-sdk \
       -v ${QT5_OPT_VOLUME_NAME}:/opt/Qt \
       -v ${SRC_VOLUME_NAME}:/usr/local/src:ro \
       -v $(pwd)/build_qt5_android.sh:/root/build_qt5_android.sh  \
       -v ${CCACHE_VOLUME}:/ccache \
      -ti --rm ${TOOLCHAIN_IMAGE_NAME} /root/build_qt5_android.sh
 
 
echo -e "-----------------${green} Build image Qtcreator and toolchain ${reset}---------------------------" 
echo [[ -d "$HOME"/docker_dev_home ]] || mkdir "$HOME"/docker_dev_home
echo docker run \
    --env "USER_ID=$(id -u ${USER})"  \
    --env "GROUP_ID=$(id -g ${USER})" \
    --mount type=bind,source="$HOME"/docker_dev_home,target=/home/developer \
    -v $(pwd)/gen_key.sh:/root/gen_key.sh \
    -ti --rm ${TOOLCHAIN_IMAGE_NAME} /root/gen_key.sh



if docker image inspect ${QTCREATOR_IMAGE_NAME} >/dev/null 2>&1; then
    echo -e "Image ${green} ${QTCREATOR_IMAGE_NAME} exists local, update.${reset}"
    #docker pull ${TOOLCHAIN_IMAGE_NAME}
else
    echo -e "Image ${green} ${QTCREATOR_IMAGE_NAME} ${red}don't exists local, ${green}build.${reset}"   
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
     cd ${BASE_DIR}     
fi

