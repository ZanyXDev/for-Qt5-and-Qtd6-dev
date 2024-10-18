# ------------------- Base images ----------------------------------------------
FROM ubuntu:22.04 AS temp_stage
ARG CMAKE_URL
ARG CMDTOOLS_URL
ARG QTCREATOR_URL

RUN echo 'cmd tools set to ${CMDTOOLS_URL}'
#I would suggest to use a second RUN instruction on your build-stage

RUN set -eux; \
    echo "go-faster apt"; \
    echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/90nolanguages;\
    echo 'APT::Get::Install-Recommends "false";'> /etc/apt/apt.conf.d/99nosuggest;\
    echo 'APT::Get::Install-Suggests "false";' >> /etc/apt/apt.conf.d/99nosuggest;\
    export DEBIAN_FRONTEND=noninteractive ;\
    apt-get -y update  ;\
    apt-get -y upgrade ;\
    apt-get -y install wget unzip; \   
    echo "install QtCreator Depends";\
    apt-get -y install libdouble-conversion3 libxcb-cursor0
    
#-----------------------  Get and install QtCreator-----------------------------
RUN wget -O /tmp/qtcreator.deb ${QTCREATOR_URL} && dpkg -i /tmp/qtcreator.deb  
#-----------------------  CMAKE-----------------------------
RUN wget -O /tmp/cmake.tar.gz ${CMAKE_URL} \
    && mkdir /opt/cmake \
    && tar -xzf /tmp/cmake.tar.gz  --strip-components=1 -C /opt/cmake 
#-----------------------  commandlinetools-linux-9477386_lates -----------------
RUN wget -O /tmp/commandlinetools.zip ${CMDTOOLS_URL} \
    && unzip /tmp/commandlinetools.zip -d /opt   
            
FROM ubuntu:22.04 AS base_dev

LABEL Description="This image based on Ubuntu 22.04,provides a base development \
                   environment (Linux and Android) for Qt developers"
ARG ANDROID_NDK_VER
ARG QT_WEBENGINE
ARG QT_WEBKIT
ARG TARGETARCH
ARG TZ
ARG USER_ID
ARG GROUP_ID

# Declare build parameters.
ENV ANDROID_NDK_ROOT=/opt/android-sdk/ndk/${ANDROID_NDK_VER}
ENV ANDROID_NDK_VER=${ANDROID_NDK_VER:-"22.1.7171670"}
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV DEBIAN_FRONTEND="noninteractive" 
ENV DISPLAY=:0
ENV HOME=/home/developer
ENV JAVA_HOME=/opt/java/openjdk
ENV LANG=ru_RU.UTF-8
ENV LANGUAGE=ru_RU:ru
ENV LC_ALL=ru_RU.UTF-8
ENV LC_LANG=ru_RU.UTF-8
ENV LD_LIBRARY_PATH=/usr/local/lib
# Add libusb dans library path
ENV OPENSSL_ROOT_DIR="/opt/android_openssl/ssl_1.1"
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV PATH="${PATH}:/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/bin:/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/libexec:/opt/qtcreator/Tools/QtCreator/bin"
ENV PATH="/opt/cmake/bin:${PATH}"
ENV PATH="/opt/cmdline-tools/bin:${PATH}"
ENV PERSIST=1
ENV PS1="\u@${BUILD_TAG}:\w\$"
ENV QML2_IMPORT_PATH="/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/qml"
ENV QML_IMPORT_PATH="/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/qml"
ENV QT_HOST_PATH="/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/"
ENV QT_PLUGIN_PATH="/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/plugins"
ENV QT_QPA_FONTDIR="/usr/share/fonts/truetype"
ENV QT_WEBENGINE=${QT_WEBENGINE:-"n"}
ENV QT_WEBKIT=${QT_WEBKIT:-"n"}
# Allow colored output on command line.
ENV TERM=xterm-color  
# Set environment variables, see Readme.md
# +Timezone (если надо на этапе сборки)
ENV TZ=Europe/Moscow
ENV xdg_runtime_dir=/run/user/"${USER_ID}"

#Troubleshooting enabling the logging categories under qt.qpa is a good idea
#in general. This will show some debug prints both from eglfs and the input handlers.
#ENV QT_LOGGING_RULES=qt.qpa.*=true

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
    echo "Qt Multimedia You'll need at least alsa-lib [>= 1.0.15] and gstreamer [>=0.10.24] with the base-plugins package.";\
    apt-get -y install  libpulse-dev libasound2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev libgstreamer-plugins-bad1.0-dev ;\
    apt-get -y install  gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-libav; \
    echo "QDoc Documentation Generator Tool Ubuntu/Debian ";\
    apt-get -y install clang libclang-dev ;\
    if ["$QT_WEBKIT" = "y"]; then \
      echo "Qt WebKit Ubuntu/Debian" >>/root/installed_deb.log;	\
      apt-get -y install flex bison gperf libicu-dev libxslt-dev ruby;\
    fi; \
    if [ "$QT_WEBENGINE" = "y" ];   then \
        echo "Qt WebEngine Ubuntu/Debian" ;\
        apt-get -y install libxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev libxtst-dev libxss-dev libdbus-1-dev libevent-dev \
	                   libcap-dev libpulse-dev libudev-dev libpci-dev libnss3-dev libasound2-dev libegl1-mesa-dev \
			           gperf bison nodejs; \
    fi;  \ 
    echo "Fontconfig library"; \
    apt-get install -y libfontconfig1-dev fontconfig;\
    apt-get install -y apt-transport-https  ca-certificates gnupg nano libssl3 openssl ;\
    echo "Wget, curl unzip"; \
    apt-get -y install wget curl unzip; \
    echo "Install X11 mini apps and  QtCreator libs";\
    apt-get install -y \
        locales sudo git libncurses5 libdouble-conversion3 libc6 libc-bin \
        libicu70 pulseaudio mc autoconf libtool xmlstarlet gdb lldb clang-format ;\
    apt-get clean -y && rm -rf /var/lib/apt/lists/*
    
# Install latest libusb
RUN set -eux; \ 
    cd /usr/local/src;\
    git clone -b v1.0.27 https://github.com/libusb/libusb; \
    cd libusb; \
    ./bootstrap.sh; \
    ./configure; \
    make; \
    make install;  \  		
    echo "/usr/local/lib" >> /etc/ld.so.conf.d/x86_64-linux-gnu.conf ;\
    echo "/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/lib" >> /etc/ld.so.conf.d/x86_64-linux-gnu.conf ;\
    /sbin/ldconfig ;\
    echo "Generate locale" ;\
    sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen ;\
    locale-gen ;\
    echo "Setup timezone" ;\
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime ;\
    echo $TZ > /etc/timezone  \  
    if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \    
      groupadd -g ${GROUP_ID} developer; \
      useradd -u ${USER_ID} -g ${GROUP_ID} developer; \
      install -d -m 0755 -o developer -g ${GROUP_ID} /home/developer; \
      adduser developer sudo; \
      echo "adding user developer to audio group"; \
      adduser	developer audio; \
      echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers; \
      mkdir -p /home/developer; \
      chown ${USER_ID}:${GROUP_ID} -R /home/developer; \
    fi
#-----------------------  Copy from other -----------------------------
# using --chown option
COPY --chown=${USER_ID}:${GROUP_ID} --from=eclipse-temurin:17 $JAVA_HOME $JAVA_HOME   
COPY --chown=${USER_ID}:${GROUP_ID} --from=temp_stage /opt/cmake /opt/cmake
COPY --chown=${USER_ID}:${GROUP_ID} --from=temp_stage /opt/qt-creator /opt/qt-creator
    
USER developer

WORKDIR /home/developer

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]

    
