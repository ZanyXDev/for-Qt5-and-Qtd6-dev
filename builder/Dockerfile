# ------------------- Base images ----------------------------------------------
FROM ubuntu:22.04 AS stage_1

LABEL Description="This image based on Ubuntu 22.04,provides a base development \
                   environment (Linux and Android) for Qt developers"
ARG QT_WEBKIT
ARG QT_WEBENGINE
ARG QT_VERSION
ARG TARGETARCH

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
ENV QT_WEBKIT=${QT_WEBKIT:-"n"}
ENV QT_WEBENGINE=${QT_WEBENGINE:-"n"}

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
    echo "Other cpp tools"; \
    apt-get install -y cppcheck graphviz doxygen git gdb lldb clang-format autoconf;\
    echo "Fontconfig library"; \
    apt-get install -y libfontconfig1-dev fontconfig;\   
    echo "Crypto tools"; \
    apt-get install -y apt-transport-https  ca-certificates gnupg libssl3 openssl ;\
    echo "#Install some libs";\
    apt-get install -y locales libncurses5 libdouble-conversion3 libc6 libc-bin libicu70  libtool xmlstarlet;\    
    echo "Libxcb packets" ;\
    apt-get -y install '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev \
                        libxcb-xinerama0-dev libxcb-xinput-dev libxcb-xkb-dev libxkbfile-dev ;\
    echo "Mesa-specific OpenGL extensions" ;\
    apt-get -y install mesa-common-dev libgl1-mesa-dev ;\ 
    echo "Qt Multimedia You'll need at least alsa-lib [>= 1.0.15] and gstreamer [>=0.10.24] with the base-plugins package."  ;\
    apt-get -y install  pulseaudio libpulse-dev ; \    
    apt-get -y install  libasound2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev libgstreamer-plugins-bad1.0-dev ;\
    apt-get -y install  gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-libav ; \    
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
    echo "Auth Tool Ubuntu/Debian " ;\
    apt-get -y install sudo nano mc ;\          
    apt-get clean -y && rm -rf /var/lib/apt/lists/*
    

FROM stage_1 AS stage_2
# Declare build parameters.
ARG QT_VERSION
ARG TARGETARCH
ARG BUILD_TAG
ARG QTCREATOR_URL
ARG USER_ID
ARG GROUP_ID
ARG QTCREATOR_URL
ARG TZ
# Set environment variables, see Readme.md
ENV DEBIAN_FRONTEND="noninteractive" 
ENV PS1="\u@${BUILD_TAG}:\w\$ "
ENV LANG=ru_RU.UTF-8
ENV LANGUAGE=ru_RU:ru
ENV LC_LANG=ru_RU.UTF-8
ENV LC_ALL=ru_RU.UTF-8
ENV QTCREATOR_URL=${QTCREATOR_URL}
ENV HOME=/home/developer
ENV PATH="${PATH}:/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/bin:/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/libexec:/opt/qtcreator/bin:${JAVA_HOME}"
ENV QT_HOST_PATH="/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/"
ENV QT_PLUGIN_PATH="/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/plugins"
ENV QML_IMPORT_PATH="/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/qml"
ENV QML2_IMPORT_PATH="/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/qml"
ENV OPENSSL_ROOT_DIR="/opt/android_openssl/ssl_1.1"
ENV DISPLAY=:0
ENV PERSIST=1
ENV QT_QPA_FONTDIR="/usr/share/fonts/truetype"
# Allow colored output on command line.
ENV TERM=xterm-color  
# +Timezone (если надо на этапе сборки)
ENV TZ=Europe/Moscow
# Add libusb dans library path
ENV LD_LIBRARY_PATH=/usr/local/lib
ENV xdg_runtime_dir=/run/user/"${USER_ID}"
#Troubleshooting
#Enabling the logging categories under qt.qpa is a good idea in general. This will show some debug prints both from eglfs and the input handlers.
#ENV QT_LOGGING_RULES=qt.qpa.*=true
ENV JAVA_HOME=/opt/java/openjdk
ENV JRE_CACERTS_PATH=/opt/java/openjdk/lib/security/cacerts
ENV JAVA_VERSION=jdk-17.0.13+11

RUN set -eux; \  	
    echo "/usr/local/lib" >> /etc/ld.so.conf.d/x86_64-linux-gnu.conf ;\
    echo "/opt/Qt/${QT_VERSION}-amd64-lts-lgpl/lib" >> /etc/ld.so.conf.d/x86_64-linux-gnu.conf ;\
    echo "/opt/Qt/${QT_VERSION}-android-lts-lgpl/lib" >> /etc/ld.so.conf.d/x86_64-linux-gnu.conf ;\
    /sbin/ldconfig ;\
    echo "Generate locale" ;\
    sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen ;\
    locale-gen ;\
    echo "Setup timezone" ;\
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime ;\
    echo $TZ > /etc/timezone ;\
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
    
USER developer

WORKDIR /home/developer
    
ENTRYPOINT [ "/bin/bash", "-l", "-c" ]    
    
