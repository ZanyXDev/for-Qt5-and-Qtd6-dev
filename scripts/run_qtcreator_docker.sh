#!/bin/bash

set -e

BUILD_OS=$(uname -s)
BUILD_DATE=$(date -u +%y%m%d)

# Enable SSH X11 forwarding inside container (https://stackoverflow.com/q/48235040)
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
chmod 777 $XAUTH

QT_VERSION="v5.15.10-lts-lgpl"
SRC_VOLUME_NAME="${QT_VERSION}-src-volume"
SDK_VOLUME_NAME="${QT_VERSION}-android-sdk-volume"
QT5_OPT_VOLUME_NAME="${QT_VERSION}-opt-volume"
TOOLCHAIN_IMAGE_NAME="zanyxdev/qt5-toolchain:${QT_VERSION}" 
QTCREATOR_IMAGE_NAME="zanyxdev/qt5-qtcreator:v12.0.0" 
CCACHE_VOLUME="${QT_VERSION}-ccache-volume"

[[ -d "$HOME"/docker_dev_home ]] || mkdir "$HOME"/docker_dev_home

./adb kill-server
./adb -a nodaemon server start &> /dev/null &

docker run --rm -it \
	--mount type=bind,source="$HOME"/docker_dev_home,target=/home/developer \
	-v $XSOCK:$XSOCK \
	-v $XAUTH:$XAUTH \
        -v ${SRC_VOLUME_NAME}:/usr/local/src:ro \
	-v ${SDK_VOLUME_NAME}:/opt/android-sdk \
	-v ${QT5_OPT_VOLUME_NAME}:/opt/Qt \
	--device=/dev/dri:/dev/dri \
	-e XAUTHORITY=$XAUTH  \
	--env "ANDROID_ADB_SERVER_ADDRESS=host.docker.internal" \
	--add-host=host.docker.internal:host-gateway \
	${QTCREATOR_IMAGE_NAME}  bash
#/opt/qtcreator/bin/qtcreator.sh
