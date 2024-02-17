#!/bin/bash

QT_VERSION="v5.15.10-lts-lgpl"
SRC_VOLUME_NAME="${QT_VERSION}-src-volume"
SDK_VOLUME_NAME="${QT_VERSION}-android-sdk-volume"
QT5_OPT_VOLUME_NAME="${QT_VERSION}-opt-volume"
TOOLCHAIN_IMAGE_NAME="zanyxdev/qt5-toolchain:${QT_VERSION}" 
QTCREATOR_IMAGE_NAME="zanyxdev/qt5-qtcreator:v12.0.0" 
CCACHE_VOLUME="${QT_VERSION}-ccache-volume"
BASE_DIR=$(pwd)

echo [[ -d "$HOME"/docker_dev_home ]] || mkdir "$HOME"/docker_dev_home
echo docker run \
    --env "USER_ID=$(id -u ${USER})"  \
    --env "GROUP_ID=$(id -g ${USER})" \
    --mount type=bind,source="$HOME"/docker_dev_home,target=/home/developer \
    -v $(pwd)/gen_key.sh:/root/gen_key.sh \
    -ti --rm ${TOOLCHAIN_IMAGE_NAME} /root/gen_key.sh

cd ${BASE_DIR}
cd ../gui
docker  build \
    --build-arg="QT_VERSION=5.15.10" \
    --build-arg="LANG=ru-RU.UTF-8" \
    --build-arg="TZ=Europe/Moscow" \
    --build-arg="USER_ID=$(id -u ${USER})"       \
    --build-arg="GROUP_ID=$(id -g ${USER})"       \
    --platform=linux/amd64 \
    --tag=${QTCREATOR_IMAGE_NAME} .
