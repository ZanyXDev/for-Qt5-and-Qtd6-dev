#!/bin/bash
docker  pull ubuntu:22.04
cd ../base

docker  build \
	--build-arg="LANG=ru-RU.UTF-8" \
	--build-arg="QT_WEBKIT=y" \
	--build-arg="QT_WEBENGINE=y" \
	--platform=linux/amd64 \
	--tag=zanyxdev/base_ubuntu_22.04_lts:latest  .
