FROM ubuntu:22.04 as source

LABEL Description="This image based on Ubuntu 22.04,provides a base development \
                   environment (Linux and Android) for Qt developers"

ENV DEBIAN_FRONTEND=noninteractive

RUN \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y update && \
    apt-get -y upgrade && \
    echo "Build essentials for ubuntu/debian" && \
    apt-get -y install build-essential perl python3 git && \
    echo "Libxcb packets" && \
    apt-get -y install '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev \
                        libxcb-xinerama0-dev libxcb-xinput-dev libxcb-xkb-dev libxkbfile-dev && \
    echo "Mesa-specific OpenGL extensions" && \
    apt-get -y install mesa-common-dev libgl1-mesa-dev && \
    echo "Qt WebKit Ubuntu/Debian" && \	
    apt-get -y install flex bison gperf libicu-dev libxslt-dev ruby && \
    echo "Qt WebEngine Ubuntu/Debian" && \	
    apt-get -y install  libxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev libxtst-dev libxss-dev libdbus-1-dev libevent-dev \
	                    libfontconfig1-dev libcap-dev libpulse-dev libudev-dev libpci-dev libnss3-dev libasound2-dev libegl1-mesa-dev \
			            gperf bison nodejs && \
    echo "Qt Multimedia You'll need at least alsa-lib (>= 1.0.15) and gstreamer (>=0.10.24) with the base-plugins package." && \
    apt-get -y install libasound2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev libgstreamer-plugins-bad1.0-dev && \
    echo "QDoc Documentation Generator Tool Ubuntu/Debian " && \
    apt-get -y install clang libclang-dev && \
    apt-get -y install nano && \
    apt clean -y && rm -rf /var/lib/apt/lists/*	    
