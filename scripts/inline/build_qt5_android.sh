#!/bin/bash
set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

pushd .
trap "popd" EXIT HUP INT QUIT TERM

export SDK_PLATFORM=android-31
export SDK_BUILD_TOOLS=31.0.0
export MIN_NDK_PLATFORM=android-21
export ANDROID_NDK_ROOT="/opt/android-sdk/ndk"
export NDK_VERSION="22.1.7171670"
export VERSION="5.15.10-android-lts-lgpl"
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=${ANDROID_HOME}
export ANDROID_NDK_ROOT=${ANDROID_HOME}/ndk/${NDK_VERSION}
export ANDROID_NDK_HOST=linux-x86_64
export ANDROID_NDK_PLATFORM=${MIN_NDK_PLATFORM}
export ANDROID_API_VERSION=${SDK_PLATFORM}
export ANDROID_BUILD_TOOLS_REVISION=${SDK_BUILD_TOOLS}
export ANDROID_NDK=$ANDROID_NDK_ROOT
export STANDALONE_EXTRA="--stl=libc++"

#rm -R /opt/Qt/${VERSION}

mkdir -p /tmp/build_qt5 
cd /tmp/build_qt5 

/usr/local/src/qt5/configure -opensource -confirm-license -xplatform android-clang -disable-rpath -android-ndk ${ANDROID_NDK_ROOT} -android-sdk ${ANDROID_HOME} \
-no-warnings-are-errors -nomake tests -nomake examples \
-qt-freetype -qt-harfbuzz -qt-libjpeg -qt-libpng -qt-pcre -qt-zlib \
-skip 3d -skip qtdocgallery -skip activeqt -skip canvas3d -skip charts -skip connectivity -skip datavis3d -skip doc -skip gamepad -skip location -skip lottie -skip macextras  \
-skip networkauth -skip qtwebengine -skip quick3d -skip quicktimeline -skip remoteobjects -skip script -skip scxml -skip sensors -skip serialbus -skip serialport -skip speech \
-skip virtualkeyboard -skip wayland -skip webchannel -skip webengine -skip webglplugin -skip websockets -skip webview -skip x11extras -skip xmlpatterns -no-feature-d3d12 -ssl \
-skip winextras \
OPENSSL_INCDIR='/opt/android-sdk/android_openssl/ssl_1.1/include/' \
OPENSSL_LIBS_DEBUG="-llibssl -llibcrypto" \
OPENSSL_LIBS_RELEASE="-llibssl -llibcrypto" \
-prefix /opt/Qt/${VERSION}

make -j $(nproc) &> /opt/Qt/$VERSION/build.log
make -j $(nproc) install 

cp config.summary /opt/Qt/$VERSION/config_android.summary 
popd >& /dev/null
