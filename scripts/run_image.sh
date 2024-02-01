#!/bin/bash

set -e

BUILD_OS=$(uname -s)
BUILD_DATE=$(date -u +%y%m%d)
BUILD_VERSION=$(git describe --always)
BUILD_TAG=${BUILD_DATE}-${BUILD_VERSION}
BUILD_ID=${BUILD_TAG}-${BUILD_OS}-$(echo "${BUILD_ARCH}" |  tr '[:lower:]' '[:upper:]')

# Enable SSH X11 forwarding inside container (https://stackoverflow.com/q/48235040)
XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
chmod 777 $XAUTH

SRC_VOLUME_NAME="source-storage"
SDK_VOLUME_NAME="androidsdk-storage"
QT5_VOLUME_NAME="qt5-binary-storage"
#mkdir "$HOME"/docker_dev_home
  
docker run --rm -it \
	-e "BUILD_TAG=${BUILD_TAG}" \
	 --mount type=bind,source="$HOME"/docker_dev_home,target=/home/developer \
	-v $XSOCK:$XSOCK \
	-v $XAUTH:$XAUTH \
    -v ${SRC_VOLUME_NAME}:/usr/local/src:ro \
	-v ${SDK_VOLUME_NAME}:/opt/android-sdk \
	-v ${QT5_VOLUME_NAME}:/opt/Qt \
	--device=/dev/dri:/dev/dri \
	-e XAUTHORITY=$XAUTH  \
	zanyxdev/qtcreator_gui:latest bash
