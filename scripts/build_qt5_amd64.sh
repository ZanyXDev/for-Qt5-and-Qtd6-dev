#!/bin/bash

echo "Temp update. not save in image"
apt-get -y update  
apt-get -y upgrade 
apt-get -y install ccache

[[ -d /tmp/build_qt ]] || mkdir /tmp/build_qt
cd /tmp/build_qt

#Solution is to configure qt with -feature-freetype -fontconfig to allow the use of system fonts
#set QT_QPA_FONTDIR to something suitable, f.ex. /usr/share/fonts/truetype/dejavu (do export QT_QPA_FONTDIR=/usr/share/fonts/truetype/dejavu before running the application)

/usr/local/src/qt5/configure  -ccache -opensource -confirm-license -dbus -qt-zlib -qt-libjpeg -qt-libpng -qt-freetype -qt-pcre -qt-harfbuzz -release -feature-freetype  \
-reduce-relocations -optimized-qmake -nomake tests -nomake examples -no-feature-d3d12 -skip 3d -skip activeqt -skip canvas3d -skip datavis3d -skip doc -skip gamepad -skip qtdocgallery \
-skip lottie -skip macextras -skip charts -skip quick3d -skip script -skip scxml -skip speech -skip virtualkeyboard -skip qtwebengine -skip webchannel -skip webengine \
-skip webglplugin -skip websockets -skip webview -skip winextras -prefix ${QT_PATH} -v -pkg-config

make -j $(nproc) &> make.log
make -j $(nproc) install 
 
cp make.log /tmp/build_qt/make.log
cp config.summary ${QT_PATH}/config.summary 
chown -R $USER_ID:$GROUP_ID ${QT_PATH}

