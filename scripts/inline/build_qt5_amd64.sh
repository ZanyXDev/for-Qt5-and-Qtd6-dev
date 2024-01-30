#!/bin/bash
set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

pushd .
trap "popd" EXIT HUP INT QUIT TERM

export VERSION="5.15.10-amd64-lts-lgpl"
mkdir -p /tmp/build_qt5 
cd /tmp/build_qt5 
/usr/local/src/qt5/configure -opensource -confirm-license -dbus -qt-zlib -qt-libjpeg -qt-libpng -qt-freetype -qt-pcre -qt-harfbuzz -release \
-reduce-relocations -optimized-qmake -nomake tests -nomake examples -no-feature-d3d12 -skip 3d -skip activeqt -skip canvas3d -skip datavis3d -skip doc -skip gamepad -skip qtdocgallery \
-skip lottie -skip macextras -skip charts -skip quick3d -skip script -skip scxml -skip speech -skip virtualkeyboard -skip qtwebengine -skip webchannel -skip webengine \
-skip webglplugin -skip websockets -skip webview -skip winextras -prefix /opt/Qt/${VERSION} -v -pkg-config

mkdir /opt/Qt/$VERSION/

cp config.summary /opt/Qt/$VERSION/config.summary 
echo "configure done..." >>/opt/Qt/$VERSION/make.summary
echo $? >>/opt/Qt/$VERSION/make.summary
make -j $(nproc) &> /opt/Qt/$VERSION/build.log
echo $? >>/opt/Qt/$VERSION/make.summary
echo "make done..." >>/opt/Qt/$VERSION/make.summary
make -j $(nproc) install 
echo $? >>/opt/Qt/$VERSION/make.summary
echo "make install ..." >>/opt/Qt/$VERSION/make.summary

popd >& /dev/null
