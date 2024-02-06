#!/bin/bash
set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

pushd .
trap "popd" EXIT HUP INT QUIT TERM

VERSION=$1
USER_ID=$2
GROUP_ID=$3

mkdir -p /tmp/build_qt5 
cd /tmp/build_qt5 

#Solution is to configure qt with -feature-freetype -fontconfig to allow the use of system fonts
#set QT_QPA_FONTDIR to something suitable, f.ex. /usr/share/fonts/truetype/dejavu (do export QT_QPA_FONTDIR=/usr/share/fonts/truetype/dejavu before running the application)

/usr/local/src/qt5/configure -opensource -confirm-license -dbus -qt-zlib -qt-libjpeg -qt-libpng -qt-freetype -qt-pcre -qt-harfbuzz -release -feature-freetype -fontconfig \
-reduce-relocations -optimized-qmake -nomake tests -nomake examples -no-feature-d3d12 -skip 3d -skip activeqt -skip canvas3d -skip datavis3d -skip doc -skip gamepad -skip qtdocgallery \
-skip lottie -skip macextras -skip charts -skip quick3d -skip script -skip scxml -skip speech -skip virtualkeyboard -skip qtwebengine -skip webchannel -skip webengine \
-skip webglplugin -skip websockets -skip webview -skip winextras -prefix /opt/Qt/${VERSION} -v -pkg-config

make -j $(nproc) &> make.log
make -j $(nproc) install 

cp make.log /opt/Qt/$VERSION/make.log
cp config.summary /opt/Qt/$VERSION/config.summary 
chown -R $USER_ID:$GROUP_ID /opt/opt/Qt/$VERSION/

popd >& /dev/null
