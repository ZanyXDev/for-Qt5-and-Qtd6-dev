#!/bin/bash
tput setab 2; reset; echo test
QT_VERSION="v5.15.10-lts-lgpl"
SRC_VOLUME_NAME="${QT_VERSION}-src-volume"
SDK_VOLUME_NAME="${QT_VERSION}-android-sdk-volume"
OPT_VOLUME_NAME="${QT_VERSION}-opt-volume"
TOOLCHAIN_IMAGE_NAME="zanyxdev/qt5-toolchain:${QT_VERSION}" 

docker run \
	  -v ${SDK_VOLUME_NAME}:/opt \
	  -v  ${SRC_VOLUME_NAME}:/usr/local/src:ro \
      -ti --rm ${TOOLCHAIN_IMAGE_NAME} bash
