#!/bin/bash
docker pull bitnami/git:latest
docker volume create source-storage

docker run \
	   -v source-storage:/local/src \
           -ti --rm --name git bitnami/git:latest bash -c '
#!/bin/bash
set -e
QT_VERSION="v5.15.10-lts-lgpl"
REPOSRC="https://invent.kde.org/qt/qt/qt5.git"
LOCALREPO="/local/src"

git clone clone --depth 1 --branch $QT_VERSION \
		"$REPOSRC" "$LOCALREPO" 2> /dev/null || (git -C "$LOCALREPO" pull)
cd  $LOCALREPO
git -c submodule."qt3d".update=none -c submodule."qtactiveqt".update=none -c submodule."qtcanvas3d".update=none  \
         -c submodule."qtdatavis3d".update=none -c submodule."qtgamepad".update=none -c submodule."qtlottie".update=none    \
         -c submodule."qtmacextras".update=none -c submodule."qtpim".update=none -c submodule."qtquick3d".update=none   \
         -c submodule."qtscript".update=none -c submodule."qtscxml".update=none -c submodule."qtspeech".update=none    \
	 -c submodule."qtvirtualkeyboard".update=none -c submodule."qtwebengine".update=none -c submodule."qtwebglplugin".update=none \
         -c submodule."qtwebsockets".update=none -c submodule."qtwebview".update=none  -c submodule."qtwinextras".update=none  \
         -c submodule."qtxmlpatterns".update=none submodule update --init --recursive
'

docker run --rm -v source-storage:/local/src -it ubuntu:22.04 /bin/bash -c "du -hs /local/src"








#--------
exit 0
git submodule update --init --recursive --depth 1
	
	
 set -e && \ 
    export version="$QT_VERSION"-lts-lgpl && \
    mkdir build && cd build && \
    ../qt5/configure -opensource -confirm-license -release -nomake tests -nomake examples \
                     -qt-zlib -qt-libjpeg -qt-libpng -xcb -qt-freetype -qt-pcre \
                     -qt-harfbuzz -prefix /opt/Qt-amd64-$version -v -pkg-config && \
    make -j $(($(nproc)+4)) && \
    
    
    
docker  build \
	--build-arg="QT_VERSION=5.15.10" \
	--build-arg="CMDVER=9477386" \
	--platform=linux/amd64 \
	--tag=zanyxdev/cmake:3.28.1  .
