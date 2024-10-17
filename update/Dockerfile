# ------------------- Base images ----------------------------------------------
FROM ubuntu:22.04 AS base_dev

LABEL Description="This image based on Ubuntu 22.04,provides a base development \
                   environment (Linux and Android) for Qt developers"
ARG QT_WEBKIT
ARG QT_WEBENGINE
ARG CMAKE_URL
ARG QT_VERSION
ARG TARGETARCH
ARG ANDROID_NDK_VER

ENV CMAKE_URL=${CMAKE_URL:-"https://github.com/Kitware/CMake/releases/download/v3.29.0/cmake-3.29.0-linux-x86_64.tar.gz"}
ENV QT_WEBKIT=${QT_WEBKIT:-"n"}
ENV QT_WEBENGINE=${QT_WEBENGINE:-"n"}
ENV ANDROID_NDK_VER=${ANDROID_NDK_VER:-"22.1.7171670"}
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_NDK_ROOT=/opt/android-sdk/ndk/${ANDROID_NDK_VER}
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV PATH="/opt/cmake/bin:${PATH}"
ENV PATH="/opt/cmdline-tools/bin:${PATH}"

RUN set -eux; \
    echo "go-faster apt"; \
    echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/90nolanguages;\
    echo 'APT::Get::Install-Recommends "false";'> /etc/apt/apt.conf.d/99nosuggest;\
    echo 'APT::Get::Install-Suggests "false";' >> /etc/apt/apt.conf.d/99nosuggest;\
    export DEBIAN_FRONTEND=noninteractive ;\
    apt-get -y update  ;\
    apt-get -y upgrade ;\
    echo "Build essentials for ubuntu/debian" ;\
    apt-get -y install build-essential perl python3 ;\
    echo "Libxcb packets" ;\
    apt-get -y install '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev \
                        libxcb-xinerama0-dev libxcb-xinput-dev libxcb-xkb-dev libxkbfile-dev ;\
    echo "Mesa-specific OpenGL extensions" ;\
    apt-get -y install mesa-common-dev libgl1-mesa-dev ;\ 
    echo "Qt Multimedia You'll need at least alsa-lib [>= 1.0.15] and gstreamer [>=0.10.24] with the base-plugins package."  ;\
    apt-get -y install  libpulse-dev libasound2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev libgstreamer-plugins-bad1.0-dev ;\
    apt-get -y install  gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-libav; \
    echo "QDoc Documentation Generator Tool Ubuntu/Debian " ;\
    apt-get -y install clang libclang-dev ;\
    if ["$QT_WEBKIT" = "y"]; then \
      echo "Qt WebKit Ubuntu/Debian" >>/root/installed_deb.log;\	
      apt-get -y install flex bison gperf libicu-dev libxslt-dev ruby; \
    fi; \
    if [ "$QT_WEBENGINE" = "y" ]; then \
        echo "Qt WebEngine Ubuntu/Debian" ;\	
        apt-get -y install libxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev libxtst-dev libxss-dev libdbus-1-dev libevent-dev \
	                   libcap-dev libpulse-dev libudev-dev libpci-dev libnss3-dev libasound2-dev libegl1-mesa-dev \
			           gperf bison nodejs; \
    fi; \      
    echo "Fontconfig library"; \
    apt-get install -y libfontconfig1-dev fontconfig;\
    apt-get install -y apt-transport-https  ca-certificates gnupg nano libssl3 openssl ;\
    echo "Wget, curl unzip"; \
    apt-get -y install wget curl unzip; \   
    apt-get clean -y ;\
    rm -rf /var/lib/apt/lists/*
#-----------------------  Copy from other -----------------------------
COPY --from=eclipse-temurin:17 $JAVA_HOME $JAVA_HOME                                   
    

    
