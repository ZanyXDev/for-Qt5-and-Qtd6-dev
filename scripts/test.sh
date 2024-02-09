#!/bin/bash

QT_VERSION="v5.15.10-lts-lgpl"
SRC_VOLUME_NAME="${QT_VERSION}-src-volume"
SDK_VOLUME_NAME="${QT_VERSION}-android-sdk-volume"
QT5_OPT_VOLUME_NAME="${QT_VERSION}-opt-volume"
TOOLCHAIN_IMAGE_NAME="zanyxdev/qt5-toolchain:${QT_VERSION}" 
QTCREATOR_IMAGE_NAME="zanyxdev/qt5-qtcreator:v12.0.0" 
CCACHE_VOLUME="${QT_VERSION}-ccache-volume"

BASE_DIR=$(pwd)

cd ${BASE_DIR}
echo docker run \
       --env "QT_PATH=/opt/Qt/5.15.10-amd64-lts-lgpl" \
       --env "USER_ID=$(id -u ${USER})"       \
       --env "GROUP_ID=$(id -g ${USER})" \
       --env "CCACHE_DIR=/ccache" \
      -v ${CCACHE_VOLUME}:/ccache \
	  -v ${SDK_VOLUME_NAME}:/opt/android-sdk \
	  -v ${QT5_OPT_VOLUME_NAME}:/opt/Qt \
	  -v ${SRC_VOLUME_NAME}:/usr/local/src:ro \
	  -v $(pwd)/build_qt5_amd64.sh:/root/build_qt5_amd64.sh  \
      -ti --rm ${TOOLCHAIN_IMAGE_NAME} /root/build_qt5_amd64.sh
