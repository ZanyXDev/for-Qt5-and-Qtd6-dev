#!/bin/bash
docker  pull ubuntu:22.04
cd ../qtcreator_gui

IMAGE_NAME="zanyxdev/qt5-toolchain:latest"
docker  build \
	--build-arg="QT_VERSION=5.15.10" \
	--platform=linux/amd64 \
	--build-arg USER_ID=$(id -u ${USER}) \
    --build-arg GROUP_ID=$(id -g ${USER}) \
	-ti --rm ${IMAGE_NAME}  .
