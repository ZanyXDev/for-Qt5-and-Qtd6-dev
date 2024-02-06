#!/bin/bash
set -e
QT_VERSION=$1
REPOSRC=$2
LOCALREPO=$3

git clone --depth 1 --branch $QT_VERSION \
		"$REPOSRC" "$LOCALREPO" 2> /dev/null || (git -C "$LOCALREPO" pull)
cd  $LOCALREPO
git -c submodule."qt3d".update=none -c submodule."qtactiveqt".update=none -c submodule."qtcanvas3d".update=none  \
         -c submodule."qtdatavis3d".update=none -c submodule."qtgamepad".update=none -c submodule."qtlottie".update=none    \
         -c submodule."qtmacextras".update=none -c submodule."qtpim".update=none -c submodule."qtquick3d".update=none   \
         -c submodule."qtscript".update=none -c submodule."qtscxml".update=none -c submodule."qtspeech".update=none    \
	 -c submodule."qtvirtualkeyboard".update=none -c submodule."qtwebengine".update=none -c submodule."qtwebglplugin".update=none \
         -c submodule."qtwebsockets".update=none -c submodule."qtwebview".update=none  -c submodule."qtwinextras".update=none  \
         -c submodule."qtxmlpatterns".update=none submodule update --init --recursive      
