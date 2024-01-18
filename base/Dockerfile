FROM ubuntu:22.04 as source

LABEL Description="This image based on Ubuntu 22.04,provides a base development\
                   environment (Linux and Android) for Qt developers"

ENV DEBIAN_FRONTEND=noninteractive

# Declare an argument for target arch and Qt version
ARG LANG

RUN \
export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install build-essential  \
    freeglut3-dev libgl1-mesa-dev libglu1-mesa-dev libjpeg-dev libmysqlclient-dev \
    libnss3-dev libopus-dev libpng-dev libsqlite3-dev libssl-dev \
    libx11-xcb-dev libxcb-xinerama0-dev libxcb-xkb-dev libxcb1-dev \
    libxcursor-dev libxi-dev libxml2-dev libxrender-dev libxslt-dev mesa-common-dev \
    zlib1g-dev '^libxcb.*-dev' libxkbcommon-dev libxkbcommon-x11-dev libwayland-dev \
    libicu-dev libxslt-dev libxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev libxtst-dev \
    libxss-dev libdbus-1-dev libevent-dev libfontconfig1-dev libcap-dev libpulse-dev libudev-dev \
    libpci-dev libnss3-dev libasound2-dev libegl1-mesa-dev libasound2-dev libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev libnspr4-dev libcups2-dev \
    libavformat-dev libavcodec-dev libavutil-dev libswresample-dev libswscale-dev libavdevice-dev \
    libmng-dev libwebp-dev libxcb-xinput-dev libwebpmux3 libvpx-dev zstd libzstd-dev \
    libpcre2-dev libclang-dev libllvm14 python3 python3-html5lib libxshmfence-dev libxkbfile-dev libbluetooth-dev \
    libsctp-dev libsnappy-dev libmd4c-dev libmd4c-html0-dev libharfbuzz-dev libminizip-dev libb2-dev libva-dev &&\
    apt clean -y && rm -rf /var/lib/apt/lists/*	

# set locales

RUN \
	if [ "$LANG_ENV" != "ru_RU.UTF8" ]; then \
	 apt-get update && apt-get install -y locales;\ 
	 sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen && locale-gen; \
    	 /usr/bin/ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone; \
	fi

# set Timezone 
ENV TZ=${TZ:-"Europe/Moscow"}    

# if LANG is null, set it to 'en_EN.UTF-8' (or leave as is otherwise).
ENV LANG=${LANG:-"en_EN.UTF-8"}
ENV LANGUAGE=${LANG:-"en_EN.UTF-8"}
ENV LC_LANG=${LANG:-"en_EN.UTF-8"}
ENV LC_ALL=${LANG:-"en_EN.UTF-8"}

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
