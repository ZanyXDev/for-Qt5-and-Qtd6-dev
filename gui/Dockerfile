FROM zanyxdev/qt5-toolchain:v5.15.10-lts-lgpl AS base
# Declare build parameters.
ARG TARGETARCH
ARG BUILD_TAG
ARG QT_VERSION
ARG QTCREATOR_URL
ARG USER_ID
ARG GROUP_ID

# Set environment variables, see Readme.md
ENV DEBIAN_FRONTEND="noninteractive" 
ENV PS1="\u@${BUILD_TAG}:\w\$ "
ENV LANG ru_RU.UTF-8
ENV LANGUAGE ru_RU:ru
ENV LC_LANG ru_RU.UTF-8
ENV LC_ALL ru_RU.UTF-8
ENV QTCREATOR_URL=${QTCREATOR_URL:-"https://github.com/qt-creator/qt-creator/releases/download/v12.0.0/qtcreator-linux-x64-12.0.0.deb"}
ENV HOME /home/developer
ENV PATH="${PATH}:/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/bin:/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/libexec:/opt/qtcreator/Tools/QtCreator/bin"
ENV QT_HOST_PATH="/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/"
ENV QT_PLUGIN_PATH="/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/plugins"
ENV QML_IMPORT_PATH="/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/qml"
ENV QML2_IMPORT_PATH="/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/qml"
ENV OPENSSL_ROOT_DIR="/opt/android_openssl/ssl_1.1"
ENV DISPLAY :0
ENV PERSIST=1
ENV QT_QPA_FONTDIR="/usr/share/fonts/truetype"

# Allow colored output on command line.
ENV TERM=xterm-color

# +Timezone (если надо на этапе сборки)
ENV TZ Europe/Moscow
  
#Install X11 mini apps and  QtCreator libs
RUN set -eux; \
    apt-get -y update \
    && apt-get install -y locales sudo mc git  wget libncurses5 libdouble-conversion3 libc6 libc-bin \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* 
    
RUN set -eux; \    
    wget -O /tmp/qtcreator.deb ${QTCREATOR_URL} \
    && dpkg -i /tmp/qtcreator.deb \
	&& rm /tmp/qtcreator.deb 
	
RUN set -eux; \  	
    echo "/opt/Qt/${QT_VERSION}-${TARGETARCH}-lts-lgpl/lib" >> /etc/ld.so.conf.d/x86_64-linux-gnu.conf \
    && /sbin/ldconfig 

RUN set -eux; \    
    if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then \    
      groupadd -g ${GROUP_ID} developer; \
      useradd -u ${USER_ID} -g ${GROUP_ID} developer; \
      install -d -m 0755 -o developer -g ${GROUP_ID} /home/developer; \
      adduser developer sudo; \
      echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers; \      
      mkdir -p /home/developer; \
      chown ${USER_ID}:${GROUP_ID} -R /home/developer; \
    fi
RUN set -eux; \    
    sed -i -e 's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen

RUN set -eux; \    
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
    
USER developer

ENV JAVA_HOME=/opt/java/openjdk
ENV xdg_runtime_dir=/run/user/"${USER_ID}"
#Troubleshooting
#Enabling the logging categories under qt.qpa is a good idea in general. This will show some debug prints both from eglfs and the input handlers.
ENV QT_LOGGING_RULES=qt.qpa.*=true

ENTRYPOINT [ "/bin/bash", "-l", "-c" ]
