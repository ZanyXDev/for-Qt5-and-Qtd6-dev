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
cd ../toolchain
  docker  build \
     --build-arg="QT_VERSION=5.15.10" \
     --build-arg="LANG=ru-RU.UTF-8" \
     --build-arg="TZ=Europe/Moscow" \
     --platform=linux/amd64 \
     --tag=${TOOLCHAIN_IMAGE_NAME} .
