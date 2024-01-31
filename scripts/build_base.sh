#!/bin/bash
docker  pull ubuntu:22.04
cd ../base

docker  build \
	--build-arg="QT_WEBKIT=n" \
	--build-arg="QT_WEBENGINE=n" \
	--platform=linux/amd64 \
	--tag=zanyxdev/base_ubuntu_22.04_lts:without_web  .
