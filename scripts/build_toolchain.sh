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

docker pull ubuntu:22.04
docker pull bitnami/git:latest
IMAGE_NAME="zanyxdev/qt5_toolchain:latest"

cd ../toolchain
echo -e "Build (rebuild) image ${green} [${IMAGE_NAME}] from srcatch ${reset}"
docker  build \
	--build-arg="QT_WEBKIT=n" \
	--build-arg="QT_WEBENGINE=n" \
	--platform=linux/amd64 \
	--tag=zanyxdev/qt5-toolchain:latest  .

exit 0


