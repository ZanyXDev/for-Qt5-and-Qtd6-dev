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

#------------------------------------------------------------------------------
# syntax=docker/dockerfile:1.4
# add COPY --link options @sa https://www.howtogeek.com/devops/how-to-accelerate-docker-builds-and-optimize-caching-with-copy-link/
# DOCKER_BUILDKIT=1 docker build -t my-image:latest .
#https://dotsandbrackets.com/persistent-data-docker-volumes-ru/
#------------------------------------------------------------------------------

SRC_VOLUME_NAME="source-storage"
SDK_VOLUME_NAME="androidsdk-storage"
QT5_VOLUME_NAME="qt5-binary-storage"
echo -e "This script used ${red}two volume${reset} ${green}[${SRC_VOLUME_NAME},${SDK_VOLUME_NAME}] ${reset}"
echo -e "${green}Don't remember's delete volumes ${red}if data they old.${reset}"

echo -e "Clone ${green} Qt5 source with KDE path${reset}"
docker run \
	   -v  ${SDK_VOLUME_NAME}:/usr/local/src \
       -ti --rm --name git bitnami/git:latest bash -c '
#!/bin/bash
set -e
QT_VERSION="v5.15.10-lts-lgpl"
REPOSRC="https://invent.kde.org/qt/qt/qt5.git"
LOCALREPO="/usr/local/src/qt5"

git clone --depth 1 --branch $QT_VERSION \
		"$REPOSRC" "$LOCALREPO" 2> /dev/null || (git -C "$LOCALREPO" pull)
cd  $LOCALREPO
git -c submodule."qt3d".update=none -c submodule."qtactiveqt".update=none -c submodule."qtcanvas3d".update=none  \
         -c submodule."qtdatavis3d".update=none -c submodule."qtgamepad".update=none -c submodule."qtlottie".update=none    \
         -c submodule."qtmacextras".update=none -c submodule."qtpim".update=none -c submodule."qtquick3d".update=none   \
         -c submodule."qtscript".update=none -c submodule."qtscxml".update=none -c submodule."qtspeech".update=none    \
	 -c submodule."qtvirtualkeyboard".update=none -c submodule."qtwebengine".update=none -c submodule."qtwebglplugin".update=none \
         -c submodule."qtwebsockets".update=none -c submodule."qtwebview".update=none  -c submodule."qtwinextras".update=none  \
         -c submodule."qtxmlpatterns".update=none submodule update --init --recursive      
'

echo -e "Clone ${green}KDAB android_openssl ${reset}"
docker run \
	  -v  ${SDK_VOLUME_NAME}:/usr/local/src \
      -ti --rm --name git bitnami/git:latest bash -c '
#!/bin/bash
set -e
REPOSRC="https://github.com/KDAB/android_openssl.git"
LOCALREPO="/usr/local/src/android_openssl"

git clone --depth 1 "$REPOSRC" "$LOCALREPO" 2> /dev/null || (git -C "$LOCALREPO" pull)
'

IMAGE_NAME="zanyxdev/qt5-toolchain:latest"      
echo -e "${green}Build Qt5.15.10-amd64-lts-lgpl tools.${reset}"   

echo docker run \
      -v ${SDK_VOLUME_NAME}:/usr/local/src:ro \
	-v ${QT5_VOLUME_NAME}:/opt/Qt \
	  -v $(pwd)/inline/build_qt5_amd64.sh:/root/build_qt5.sh  \
      -ti --rm ${IMAGE_NAME} /root/build_qt5.sh
      
echo -e "${green}Update android-sdk tools [minimum images] ${reset}"      

echo docker run \
	  -v ${SDK_VOLUME_NAME}:/opt/android-sdk \
	  -v ${QT5_VOLUME_NAME}:/opt/Qt \
	  -v $(pwd)/inline/get_androidsdk.sh:/root/get_androidsdk.sh  \
      -ti --rm ${IMAGE_NAME} /root/get_androidsdk.sh

echo -e "${blue}Build Qt5.15.10-android-lts-lgpl tools.${reset}"  
docker run \
      -v ${SDK_VOLUME_NAME}:/usr/local/src:ro \
	  -v ${QT5_VOLUME_NAME}:/opt/Qt \
	  -v ${SDK_VOLUME_NAME}:/opt/android-sdk \
	  -v $(pwd)/inline/build_qt5_android.sh:/root/build_android.sh  \
      -ti --rm ${IMAGE_NAME}  /root/build_android.sh 
exit 0       	  
